# Accepted risks & compensating controls

Risk-acceptance register for CIS AWS Foundations Benchmark v6.0.0 controls that are **not
enforced as the benchmark literally prescribes**, due to the **< $1/month cost target**.
Each item records the residual risk and the compensating control that mitigates it. Owner map:
[`controls-matrix.md`](../../controls-matrix.md). Re-evaluate at each quarterly review or if
the budget changes.

| # | Control | Lvl | Decision | Residual risk | Compensating control | Re-enable |
| --- | --- | --- | --- | --- | --- | --- |
| R-1 | 4.3 AWS Config in all regions | L2 | Not deployed | No continuous, point-in-time config history / timeline | Scheduled **Prowler** scan (`cis-scan.yml`) reads live config across all regions + all CIS checks; **`terraform plan`** in CI flags guardrail drift on every PR | `enable_aws_config = true` |
| R-2 | 5.16 AWS Security Hub | L2 | Not deployed | No in-console aggregated CIS scorecard | **Prowler** runs the same CIS benchmark on a schedule and emits the JSON scorecard | `enable_security_hub = true` |
| R-3 | 4.5 CloudTrail logs encrypted with KMS CMK | L2 | SSE-S3 (AES256) instead of a customer-managed key | Logs not encrypted with a customer-controlled, auditable, revocable key | Logs are still encrypted at rest (AES256), object-versioned, TLS-only, and public-access-blocked; trail has log-file validation | `create_kms_key = true` (+$1/mo) |
| R-4 | 5.1–5.15 monitoring | L1/L2 | EventBridge→SNS instead of CloudWatch metric-filter alarms | Prowler will still flag 5.1–5.15 as FAIL (it checks for the metric filters); home-region rules do not catch **network**-change events (5.10–5.14) in other regions | Free **EventBridge** rules notify SNS on the same CloudTrail events in the home region (all global-service events); periodic **Prowler** scan covers all regions for the network controls | Add paid alarms, or per-region EventBridge + cross-region bus |

## What is NOT an accepted risk

The free, high-value guardrails remain **fully enforced**: CloudTrail (4.1, multi-region,
log-file validation), IAM External Access Analyzer in all regions (2.19), EBS default
encryption in all regions (6.1.1), default-security-group lockdown (6.5), IAM password policy
(2.7/2.8), account + security contacts (2.1/2.2), AWS Support role (2.16), and account-level
S3 Block Public Access (3.1.4).

## Manual / process controls

CIS controls that no IaC can fully enforce (root MFA, credential rotation, periodic access
review, etc.) are not "accepted risks" — they are owned by the security policies in this
directory and verified by the periodic Prowler scan. See `controls-matrix.md` for the list.
