# Controls matrix — CIS AWS Foundations Benchmark v6.0.0

Maps **every** control in the benchmark (63 total) to **who enforces it** and **where**.
Control IDs / titles / profile levels are taken from the authoritative Prowler mapping
[`cis_6.0_aws.json`](https://raw.githubusercontent.com/prowler-cloud/prowler/master/prowler/compliance/aws/cis_6.0_aws.json).

Live status for the M12 epic: [Token-Buzz/website#130](https://github.com/Token-Buzz/website/issues/130).

## Ownership model

| Owner | Meaning | Lives in |
| --- | --- | --- |
| **TF-account** | Account/org-wide guardrail | **this repo** — `modules/*` wired by `environments/org-foundation/` |
| **SST-app** | Tied to an app resource SST creates | `Token-Buzz/website` (`infra/*.ts`) |
| **Manual** | Process / org control; IaC cannot fully enforce | `docs/policies/` + evidence |
| **Split** | Needs both an account-level and a per-resource piece | both |

> **Why the split?** Resource-scoped controls (a bucket's encryption, a CloudFront TLS
> policy) must live with the resource that SST owns, or they drift. Account/org guardrails
> (CloudTrail, Config, Access Analyzer, alarms) are app-independent and belong in a
> security-owned Terraform state with a tightly-scoped role — this repo.

## Section 2 — Identity and Access Management

| ID | Title | Lvl | Owner | Implemented in / note |
| --- | --- | --- | --- | --- |
| 2.1 | Maintain current contact details | L1 | TF-account | `modules/iam-baseline` (`aws_account_primary_contact`) |
| 2.2 | Security contact information registered | L1 | TF-account | `modules/iam-baseline` (`aws_account_alternate_contact` SECURITY) |
| 2.3 | No 'root' user access key exists | L1 | Manual | Root keys not TF-manageable; detect via Prowler |
| 2.4 | MFA enabled for 'root' user | L1 | Manual | Console-only; policy + evidence |
| 2.5 | Hardware MFA for 'root' user | L2 | Manual | Physical action; policy + evidence |
| 2.6 | Eliminate use of 'root' for daily tasks | L1 | Manual | Behavioral; access-control policy |
| 2.7 | IAM password policy length ≥ 14 | L1 | TF-account | `modules/iam-baseline` (`aws_iam_account_password_policy`) |
| 2.8 | IAM password policy prevents reuse (24) | L1 | TF-account | `modules/iam-baseline` |
| 2.9 | MFA for all IAM users with console password | L1 | Manual | Per-user enrollment; consider SCP deny-no-MFA |
| 2.10 | No access keys at initial user setup | L1 | Manual | Process; partially preventable via SCP |
| 2.11 | Disable credentials unused ≥ 45 days | L1 | Manual | Operational hygiene; detect-only |
| 2.12 | Only one active access key per user | L1 | Manual | Per-user; detect-only |
| 2.13 | Access keys rotated ≤ 90 days | L1 | Manual | Operational; detect-only |
| 2.14 | IAM users receive permissions via groups | L1 | **Split / TBD** | TF-account *iff* our TF owns the IAM principals — see "open facts" |
| 2.15 | No `*:*` administrative policies attached | L1 | **Split / TBD** | TF-account for TF-managed policies; detect elsewhere |
| 2.16 | Support role for AWS Support created | L1 | TF-account | `modules/iam-baseline` (`create_support_role`) |
| 2.17 | IAM instance roles for EC2 resource access | L2 | SST-app | Per-instance; **N/A if serverless** |
| 2.18 | Remove expired SSL/TLS certs from IAM | L1 | Manual | Cleanup task; detect-only |
| 2.19 | IAM External Access Analyzer in all regions | L1 | TF-account | `modules/access-analyzer` (per region, ORGANIZATION) |
| 2.20 | IAM identities managed centrally (federation) | L2 | Manual | Org identity architecture |
| 2.21 | Restrict `AWSCloudShellFullAccess` | L1 | TF-account *(planned)* | SCP / permission boundary — not yet built |

## Section 3 — Storage

| ID | Title | Lvl | Owner | Implemented in / note |
| --- | --- | --- | --- | --- |
| 3.1.1 | S3 bucket policy denies HTTP (TLS-only) | L2 | SST-app | Per-bucket policy on app buckets |
| 3.1.2 | MFA Delete enabled on S3 buckets | L2 | Manual | Requires root + CLI; not TF-settable |
| 3.1.3 | All S3 data classified/secured (Macie) | L2 | TF-account *(planned)* | `aws_macie2_account` (cost — off by default) + process |
| 3.1.4 | S3 'Block Public Access' enabled | L1 | **Split** | Account-level → `modules/iam-baseline`; per-bucket → SST-app |
| 3.2.1 | RDS encryption-at-rest | L1 | SST-app | Per-RDS; **N/A if no RDS** |
| 3.2.2 | RDS auto minor version upgrade | L1 | SST-app | Per-RDS; **N/A if no RDS** |
| 3.2.3 | RDS not publicly accessible | L1 | SST-app | Per-RDS; **N/A if no RDS** |
| 3.2.4 | RDS Multi-AZ | L1 | SST-app | Per-RDS; **N/A if no RDS** |
| 3.3.1 | EFS encryption-at-rest | L1 | SST-app | Per-EFS; **N/A if no EFS** |

## Section 4 — Logging

| ID | Title | Lvl | Owner | Implemented in / note |
| --- | --- | --- | --- | --- |
| 4.1 | CloudTrail enabled in all regions | L1 | TF-account | `modules/cloudtrail` (multi-region org trail) |
| 4.2 | CloudTrail log file validation | L2 | TF-account | `modules/cloudtrail` (`enable_log_file_validation`) |
| 4.3 | AWS Config enabled in all regions | L2 | TF-account | `modules/config` (per region) |
| 4.4 | Server access logging on CloudTrail S3 bucket | L1 | TF-account *(planned)* | Add access-log target to trail bucket — see "open facts" |
| 4.5 | CloudTrail logs encrypted with KMS CMK | L2 | TF-account | `modules/cloudtrail` (dedicated CMK) |
| 4.6 | Rotation enabled for customer symmetric CMKs | L2 | Split | Our CMKs → `modules/cloudtrail` (rotation on); app CMKs → SST |
| 4.7 | VPC flow logging in all VPCs | L2 | Split | `modules/vpc-baseline` (default VPC, opt-in/cost); app VPCs → SST |
| 4.8 | S3 object-level **write** logging | L2 | TF-account | `modules/cloudtrail` (write data events, all buckets) |
| 4.9 | S3 object-level **read** logging | L2 | TF-account | `modules/cloudtrail` (read data events, **scoped allowlist** for cost) |

## Section 5 — Monitoring

All 5.1–5.15 = CloudWatch Logs metric filter + alarm over the CloudTrail log group →
`modules/monitoring-alarms`. 5.16 = Security Hub → `modules/security-hub`.
**Dependency:** these only pass once the 4.1 trail is wired to CloudWatch Logs (it is).

| ID | Title | Lvl | Owner | Implemented in |
| --- | --- | --- | --- | --- |
| 5.1 | Unauthorized API calls | L2 | TF-account | `modules/monitoring-alarms` |
| 5.2 | Console sign-in without MFA | L1 | TF-account | `modules/monitoring-alarms` |
| 5.3 | Usage of 'root' account | L1 | TF-account | `modules/monitoring-alarms` |
| 5.4 | IAM policy changes | L1 | TF-account | `modules/monitoring-alarms` |
| 5.5 | CloudTrail config changes | L1 | TF-account | `modules/monitoring-alarms` |
| 5.6 | Console authentication failures | L2 | TF-account | `modules/monitoring-alarms` |
| 5.7 | Disable / scheduled deletion of CMKs | L2 | TF-account | `modules/monitoring-alarms` |
| 5.8 | S3 bucket policy changes | L1 | TF-account | `modules/monitoring-alarms` |
| 5.9 | AWS Config config changes | L2 | TF-account | `modules/monitoring-alarms` |
| 5.10 | Security group changes | L2 | TF-account | `modules/monitoring-alarms` |
| 5.11 | NACL changes | L2 | TF-account | `modules/monitoring-alarms` |
| 5.12 | Network gateway changes | L1 | TF-account | `modules/monitoring-alarms` |
| 5.13 | Route table changes | L1 | TF-account | `modules/monitoring-alarms` |
| 5.14 | VPC changes | L1 | TF-account | `modules/monitoring-alarms` |
| 5.15 | AWS Organizations changes | L1 | TF-account | `modules/monitoring-alarms` |
| 5.16 | AWS Security Hub enabled | L2 | TF-account | `modules/security-hub` (CIS standard subscription) |

## Section 6 — Networking

| ID | Title | Lvl | Owner | Implemented in / note |
| --- | --- | --- | --- | --- |
| 6.1.1 | EBS volume encryption (default, all regions) | L1 | TF-account | `modules/vpc-baseline` (`aws_ebs_encryption_by_default`) |
| 6.1.2 | CIFS (445) restricted to trusted networks | L1 | SST-app | Per-SG; **N/A if no file shares** |
| 6.2 | No NACL ingress 0.0.0.0/0 to 22/3389 | L1 | **Split / TBD** | TF-account if TF owns NACLs; else per-VPC |
| 6.3 | No SG ingress 0.0.0.0/0 to admin ports | L1 | SST-app | Per-SG |
| 6.4 | No SG ingress ::/0 to admin ports (IPv6) | L1 | SST-app | Per-SG |
| 6.5 | Default SG of every VPC restricts all traffic | L2 | TF-account | `modules/vpc-baseline` (`aws_default_security_group`) |
| 6.6 | VPC peering route tables least-access | L2 | Manual | Network owner |
| 6.7 | EC2 metadata service IMDSv2 only | L1 | SST-app | Per-instance; **N/A if serverless** |

## Owner summary

| Owner | Count | Notes |
| --- | ---: | --- |
| TF-account (this repo) | ~28 | incl. 3 planned: 2.21, 3.1.3, 4.4 |
| SST-app (`website`) | ~10 | several **N/A** if the app is fully serverless |
| Manual / process | ~12 | tracked in `docs/policies/` + evidence |
| Split / TBD | ~5 | 2.14, 2.15, 3.1.4, 4.6, 4.7, 6.2 |

## Open facts to confirm (these change ownership / applicability)

1. **Does the SST app use EC2 / RDS / EFS / its own VPC?** If it is fully serverless
   (Lambda + DynamoDB + S3 + CloudFront), then 2.17, 3.2.1–3.2.4, 3.3.1, 6.1.2, 6.7 are
   **Not Applicable**, not "SST-owned TODO".
2. **Who creates IAM principals (users/roles/policies)?** Decides whether 2.14 / 2.15 are
   TF-account-enforceable or detect-only.
3. **Who owns the VPC(s)?** Decides 4.7 / 6.2 / 6.3 ownership (app VPC → SST; shared/default
   VPC → here). 6.5 (default SG lockdown) is ours regardless.
4. **Planned TF-account additions not yet built:** 2.21 (CloudShell SCP), 3.1.3 (Macie,
   cost-gated), 4.4 (trail-bucket server access logging).
