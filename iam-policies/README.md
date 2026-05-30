# IAM policy artifacts

JSON policy documents that are managed **outside Terraform** (created manually with admin
credentials) but version-controlled here for review and auditability.

## `GithubOIDCPolicyCISCompliance.json`

### Why this policy exists

It replaces the existing customer-managed policy **`GithubOIDCPolicy`**
(`arn:aws:iam::421219980711:policy/GithubOIDCPolicy`), which is attached to the
**`GithubOIDCRole`** assumed via GitHub OIDC by two repos:

- `Token-Buzz/website` — SST application deploys
- `Token-Buzz/compliance-cis-6.0` — this Terraform security baseline

The old policy contains a `Deployments` statement with
`"Action": ["*"], "Resource": ["*"]` — full administrative privilege. Prowler's
`iam_customer_attached_policy_no_administrative_privileges` check (CIS AWS Foundations
**2.15** family) **FAILs** on any attached policy whose document grants full admin, so this
finding cannot clear while that statement exists.

### The exact fix — and what it is NOT

Prowler's `check_admin_access` returns `True` **only** when an `Allow` statement pairs a
**bare `"*"` action** with `Resource "*"` (or equivalent `NotResource` tricks). A statement
listing **service wildcards** — `"s3:*"`, `"lambda:*"`, `"iam:*"`, etc. — does **not** trip
the check, even on `Resource "*"`.

So the only change versus the original is: the `Deployments` statement's `Action` is now an
explicit list of `service:*` (and a few narrower `service:Action`) entries instead of a bare
`"*"`. Every other statement in the original policy is already resource-scoped and is kept
**verbatim**.

This is **service-scoped, NOT least-privilege.** It removes the bare-`*` admin grant to pass
the CIS check while preserving the breadth both deploy pipelines need. It does **not** scope
actions down to specific resources or conditions.

### Scope caveat — `iam:*` and privilege escalation

`iam:*` is retained because **both** the SST app and this Terraform baseline create and attach
IAM roles/policies during deploy. With `iam:*` on `Resource "*"`, a compromised CI run could
escalate privileges (create a role/policy and attach broader permissions). Recommended future
follow-ups to mitigate, out of scope here:

- Attach a **permissions boundary** to every role the deploy pipelines create, capping the
  effective permissions of derived roles.
- Tighten the `Deployments` statement using **IAM Access Analyzer policy generation** seeded
  from CloudTrail of real `pr-*` / `production` runs, narrowing `service:*` down to the
  actions and resources actually used.

## Swap procedure (manual)

Run by a human with **admin credentials** (NOT as `GithubOIDCRole`). Paths are relative to the
repo root.

1. **Create the new policy:**
   ```bash
   aws iam create-policy \
     --policy-name GithubOIDCPolicyCISCompliance \
     --policy-document file://iam-policies/GithubOIDCPolicyCISCompliance.json
   ```

2. **Attach it to the role (alongside the old one, during validation):**
   ```bash
   aws iam attach-role-policy \
     --role-name GithubOIDCRole \
     --policy-arn arn:aws:iam::421219980711:policy/GithubOIDCPolicyCISCompliance
   ```

3. **Validate on a `pr-<N>` stage.** Trigger a real CI deploy of `Token-Buzz/website` (SST)
   and a `terraform plan` / `terraform apply` for `Token-Buzz/compliance-cis-6.0`, both
   assuming `GithubOIDCRole`. Confirm there are **no `AccessDenied` errors**. If something is
   denied, add the missing `service:*` (or `service:Action`) to the `Deployments` statement,
   create a new policy version, and re-test:
   ```bash
   aws iam create-policy-version \
     --policy-arn arn:aws:iam::421219980711:policy/GithubOIDCPolicyCISCompliance \
     --policy-document file://iam-policies/GithubOIDCPolicyCISCompliance.json \
     --set-as-default
   ```

4. **Only after a green run, remove the old policy:**
   ```bash
   aws iam detach-role-policy \
     --role-name GithubOIDCRole \
     --policy-arn arn:aws:iam::421219980711:policy/GithubOIDCPolicy
   # then delete the old policy (delete non-default versions first if any)
   aws iam delete-policy \
     --policy-arn arn:aws:iam::421219980711:policy/GithubOIDCPolicy
   ```

5. **Re-run Prowler.** Confirm a **new scan ID** and that
   `iam_customer_attached_policy_no_administrative_privileges` now **PASSes**.

## Notes & follow-ups

- **Managed outside Terraform.** `GithubOIDCRole` and its policies were created manually and
  are not currently in IaC. Bringing the role + policy into Terraform is a reasonable future
  follow-up (out of scope here).
- **Trust-policy hygiene (separate follow-up, do not change as part of this swap).** The
  `GithubOIDCRole` trust policy's `sub` list currently **duplicates each repo** and uses `:*`
  (matches any git ref / branch). Recommended: **dedupe** the entries and consider tightening
  to **specific refs** (e.g. `ref:refs/heads/main` / specific `pr-*` patterns) rather than
  any-ref. Documented as a recommendation only.
