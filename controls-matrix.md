# Controls matrix

Maps each control to where it is implemented (the M12 phase, the PR, and the IaC file or
setting that enforces it). Populated as phases land — see
[Token-Buzz/website#130](https://github.com/Token-Buzz/website/issues/130).

| Control area | CIS / source reference | M12 phase | Implemented in | Status |
| --- | --- | --- | --- | --- |
| CIS-AWS baseline captured | CIS AWS Foundations | Phase 1 | `baselines/<date>/` | TODO |
| Root account locked (no keys, MFA, alarm) | CIS 1.x | Phase 2 | account config | TODO |
| OIDC deploy role least-privilege | — | Phase 2 / 6 | `website` IaC | TODO |
| CloudTrail multi-region + validation | CIS 3.x | Phase 3 | `website/infra/logging.ts` | TODO |
| AWS Config + Security Hub CIS standard | CIS 3.x | Phase 3 | account config | TODO |
| S3 Block Public Access + SSE + TLS-only | CIS 2.x | Phase 4 | `website/infra` | TODO |
| DynamoDB at-rest / KMS decision | CIS 2.x | Phase 4 | `website/infra/db.ts` | TODO |
| CloudFront HTTPS-only + min TLS | CIS 2.x | Phase 5 | `website/infra/router.ts` | TODO |
| Actions pinned to SHAs + min permissions | supply chain | Phase 6 | `website/.github/` | TODO |
| Branch protection on `master` | supply chain | Phase 6 | repo settings | TODO |
| Dependabot / secret scanning / CodeQL / SBOM | supply chain | Phase 7 | `website/.github/` | TODO |
| Policy set + vendor/data-flow register | GRC | Phase 8 | `docs/policies/` | TODO |
| Continuous re-scan + drift alerting + scorecard | GRC | Phase 9 | `.github/workflows/cis-scan.yml` | TODO |
