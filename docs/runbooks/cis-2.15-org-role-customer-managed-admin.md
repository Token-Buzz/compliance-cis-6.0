# Runbook — CIS 2.15: swap `OrganizationAccountAccessRole` to a customer-managed admin policy

**Control:** CIS AWS Foundations 2.15 — *"Ensure IAM policies that allow full `*:*`
administrative privileges are not attached."*
**Target:** the role `OrganizationAccountAccessRole` in this **member** account.
**Goal:** keep identical admin capability, but expressed as a **customer-managed** policy so
Prowler's check (`iam_aws_attached_policy_no_administrative_privileges`) stops flagging it.

> This is a **manual, console/CLI runbook**, not Terraform. `OrganizationAccountAccessRole`
> is auto-created by AWS Organizations and is **not** managed in this repo's state. Do **not**
> import it into Terraform — that would make this repo responsible for the org's recovery path.

---

## Why this works

Prowler 2.15 only evaluates **AWS-managed** policies (`policy.type == "AWS"`) that are
attached and grant `*:*`. The default `arn:aws:iam::aws:policy/AdministratorAccess` is exactly
that → FAIL. A **customer-managed** policy with the same `{"Action":"*","Resource":"*"}`
document is functionally identical admin but is excluded from the check (`type != "AWS"`), so
the role passes while losing **no** capability.

This does **not** change the trust policy. The role still trusts only the management account
(`arn:aws:iam::172106476397:root`); we only swap *what the role can do*, not *who can assume it*.

## Trade-off (read before running)

You are giving up AWS's maintained `AdministratorAccess` policy in favour of one **you** now
own. It is `*:*`, so there is nothing to keep in sync today — but it is your object to audit.
If you would rather not own the org recovery role's policy, **do not run this** — accept the
risk instead (see `../policies/accepted-risks.md`, entry R-5).

---

## Preconditions

- [ ] You can authenticate to **this member account** with an identity that has
      `iam:CreatePolicy`, `iam:AttachRolePolicy`, `iam:DetachRolePolicy`,
      `iam:ListAttachedRolePolicies` (e.g. the `provisioner` user or the break-glass role).
- [ ] **You are NOT authenticated *as* `OrganizationAccountAccessRole`.** Editing the role you
      are currently using risks cutting off your own session if a step half-fails. Use a
      *different* admin identity so the role is a passive target.
- [ ] You know the management-account ID is `172106476397` (used only to sanity-check the trust
      is untouched — you will not log into it).

> **Can I do this from the member account?** Yes. The role, the new policy, and the
> attach/detach all live in this member account. No management-account login required.

---

## Procedure (attach-new → verify → detach-old)

Order matters: we attach the replacement **before** detaching the default, so the role is
never under-privileged. Momentarily having two admin policies is harmless; having zero is the
hazard.

Set a variable for the account ID to keep commands copy-paste safe:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Operating in member account: $ACCOUNT_ID"   # sanity-check this is the member, not 172106476397
```

### 0. Snapshot current state (for rollback evidence)

```bash
aws iam list-attached-role-policies --role-name OrganizationAccountAccessRole
# Expect exactly: AdministratorAccess (arn:aws:iam::aws:policy/AdministratorAccess)
```

### 1. Create the customer-managed admin policy

```bash
cat > /tmp/org-admin.json <<'JSON'
{
  "Version": "2012-10-17",
  "Statement": [
    { "Sid": "FullAdmin", "Effect": "Allow", "Action": "*", "Resource": "*" }
  ]
}
JSON

aws iam create-policy \
  --policy-name OrgAccountAccessAdmin \
  --description "Customer-managed full admin for OrganizationAccountAccessRole (CIS 2.15: replaces AWS-managed AdministratorAccess). Identical *:* grant; owned/audited in-account." \
  --policy-document file:///tmp/org-admin.json
```

Capture the returned ARN:

```bash
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/OrgAccountAccessAdmin"
```

### 2. Attach the new policy (role now has BOTH — safe)

```bash
aws iam attach-role-policy \
  --role-name OrganizationAccountAccessRole \
  --policy-arn "$POLICY_ARN"
```

### 3. Verify the role can still do admin BEFORE removing the default

From a **separate terminal / session**, assume the role from the management account exactly as
your real workflow does, and confirm an admin action works (e.g. `aws iam list-roles` or
whatever your normal break-glass smoke test is). Do **not** proceed until this is confirmed
green. Both policies are attached at this point, so this proves the new policy path works.

```bash
aws iam list-attached-role-policies --role-name OrganizationAccountAccessRole
# Expect BOTH: AdministratorAccess AND OrgAccountAccessAdmin
```

### 4. Detach the AWS-managed default

```bash
aws iam detach-role-policy \
  --role-name OrganizationAccountAccessRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### 5. Confirm final state

```bash
aws iam list-attached-role-policies --role-name OrganizationAccountAccessRole
# Expect ONLY: OrgAccountAccessAdmin
```

---

## Verify the control flips

Re-run the scan and confirm 2.15 has no remaining findings (assuming `provisioner` has also
been remediated — that is the *other* `AdministratorAccess` attachment):

```bash
# however cis-scan is invoked in this repo / CI
prowler aws -c iam_aws_attached_policy_no_administrative_privileges
```

A new Prowler **Scan ID** must appear (Prowler caches by scan ID). 2.15 should report PASS for
both the user and the role once `provisioner` no longer carries AWS-managed admin.

---

## Rollback

Fully reversible — re-attach the AWS-managed default and remove the custom policy:

```bash
aws iam attach-role-policy \
  --role-name OrganizationAccountAccessRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

aws iam detach-role-policy \
  --role-name OrganizationAccountAccessRole \
  --policy-arn "$POLICY_ARN"

# optional: aws iam delete-policy --policy-arn "$POLICY_ARN"
```

---

## Notes / gotchas

- **Trust untouched.** Do not edit `AssumeRolePolicyDocument`; recovery from the management
  account must keep working. If you ever recreate the role, AWS re-attaches the AWS-managed
  `AdministratorAccess` by default — this swap must be redone, so keep this runbook.
- **Not in Terraform.** Leaving this out of state is deliberate. If a future decision moves org
  baseline into IaC (management-account level), revisit then.
- **The other 2.15 attachment** is the `provisioner` user. 2.15 stays FAIL until *both* the user
  and this role are off AWS-managed `AdministratorAccess`. See the IAM remediation work on
  branch `claude/jolly-edison-V4v19` (groups + break-glass role).
- **If you skip this:** record entry **R-5** in `../policies/accepted-risks.md` so the residual
  is a documented, owned decision rather than an open finding.
