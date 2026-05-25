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
| `controls-matrix.md` | Each CIS / CI-CD control → implementing phase / PR / IaC file |
| `docs/policies/` | Security policy set (access control, change mgmt, logging, IR, vendor) |
| `baselines/<date>/` | Dated Prowler CIS-AWS baseline runs (HTML + JSON) + config |
| `evidence/<date>/` | Point-in-time evidence: scan exports, SBOMs, attestations |
| `.github/workflows/cis-scan.yml` | Scheduled Prowler re-scan + drift alerting (Phase 9) |

## Benchmark tool

**Prowler v4** (CIS AWS Foundations) — a single read-only IAM-role run, CIS-native with
per-check severity + remediation, emitting JSON reused by the continuous-monitoring scorecard.
