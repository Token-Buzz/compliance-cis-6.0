# compliance

Security & compliance artifacts for **Token-Buzz**, aligned to **CIS benchmarks**.

This repo holds the deliverable artifacts of milestone **M12 — Security & Compliance**:
policy documents, the controls-mapping matrix, the CIS benchmark (Prowler) configuration,
dated baseline/evidence exports, and the scheduled re-scan workflow + scorecard.

The roadmap **spec, epic, and phase issues live in `Token-Buzz/website`** (for continuity
with milestones M1–M11), and both repos are tracked on the shared **GitHub Project #1**.

- Milestone spec: [`docs/milestones/M12-security-compliance.md`](https://github.com/Token-Buzz/website/blob/master/docs/milestones/M12-security-compliance.md) (in `website`)
- Epic / live status: [Token-Buzz/website#130](https://github.com/Token-Buzz/website/issues/130)

## Scope

1. **AWS / cloud config** — CIS AWS Foundations Benchmark against the SST/AWS account.
2. **CI/CD & supply chain** — pinned actions, least-privilege OIDC, branch protection, dependency/secret/code scanning, SBOM + provenance.
3. **Compliance program** — controls mapping, policies, evidence collection, continuous monitoring.

Out of scope: OS/host CIS baselines (the stack is serverless — no long-lived hosts).

## Layout

| Path | Purpose |
| --- | --- |
| `controls-matrix.md` | Every CIS v6.0.0 control → owner (TF here / SST / manual) + IaC file |
| `modules/` | Reusable Terraform modules enforcing the account/org CIS guardrails |
| `environments/org-foundation/` | Root that wires the modules across all active regions |
| `global/backend-bootstrap/` | One-time S3 + DynamoDB remote-state backend bootstrap |
| `docs/policies/` | Security policy set (access control, change mgmt, logging, IR, vendor) |
| `baselines/<date>/` | Dated Prowler CIS-AWS baseline runs (HTML + JSON) + config |
| `evidence/<date>/` | Point-in-time evidence: scan exports, SBOMs, attestations |
| `.github/workflows/terraform.yml` | `fmt` + `validate` + lint gate on PRs |
| `.github/workflows/cis-scan.yml` | Scheduled Prowler re-scan + drift alerting (Phase 9) |

## Terraform enforcement

This repo enforces the **account/org-wide** CIS guardrails. To stay under a **< $1/month**
budget, the default deployment keeps the **free** controls (CloudTrail, IAM Access Analyzer,
EBS default encryption, default-SG lockdown, IAM password policy / contacts / support role,
account S3 Block Public Access) and swaps the paid ones for **compensating controls**: AWS
Config and Security Hub are **off by default** (covered by the scheduled Prowler scan +
`terraform plan` drift), CloudTrail uses free **SSE-S3** (not a KMS CMK), and the CIS 5.x
monitoring uses free **EventBridge → SNS** rules instead of paid CloudWatch alarms. Each can
be re-enabled with its toggle. See [`docs/policies/accepted-risks.md`](docs/policies/accepted-risks.md)
and the "Cost posture" section of `controls-matrix.md`.

**Resource-scoped** controls (per-bucket S3 settings, CloudFront TLS, DynamoDB encryption)
stay with the resources SST owns in `Token-Buzz/website`. `controls-matrix.md` is the
authoritative per-control owner map.

```bash
# 1. one-time: create the remote-state backend (uses local state)
cd global/backend-bootstrap && terraform init && terraform apply   # CONFIRM FIRST

# 2. the guardrails (run from the Org management / delegated-admin account)
cd environments/org-foundation
terraform init -backend-config=backend.hcl
cp terraform.tfvars.example terraform.tfvars   # fill required values; never commit it
terraform plan -var-file=terraform.tfvars      # review with the user before any apply
```

> Applied from the AWS Organization **management or delegated-admin** account (org CloudTrail,
> ORGANIZATION-type Access Analyzer, Config aggregator). Home region is `us-east-1`. S3 read
> data-event logging (CIS 4.9) is scoped to `s3_read_event_bucket_arns` to cap cost.

## Benchmark tool

**Prowler v4** (CIS AWS Foundations) — a single read-only IAM-role run, CIS-native with
per-check severity + remediation, emitting JSON reused by the continuous-monitoring scorecard.

## Evidence

This screenshot provides evidence of baseline hardening proven through a Prowler Compliance scan.
<img width="2243" height="995" alt="image" src="https://github.com/user-attachments/assets/6896b400-c6a8-40ea-b752-2bba7461e71e" />

