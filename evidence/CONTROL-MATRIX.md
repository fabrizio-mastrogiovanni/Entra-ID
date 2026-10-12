# Control Matrix: Identity and Access

Evidence collected: 2026-10-12
Period: Q4 2026

| # | Control | How it is implemented | Evidence | Status |
|---|---|---|---|---|
| 1 | Access granted through groups, not individuals | Group-based licensing and access groups | `access-review-*.csv`, Groups column | Met |
| 2 | Departed users lose access promptly | Documented offboarding sequence | `RUNBOOK.md`, `offboarding-log.txt` | Met |
| 3 | Sessions revoked at offboarding | `Revoke-MgUserSignInSession` in step 2 | Offboarding log | Met |
| 4 | Disabled accounts hold no licenses | Export flags `DISABLED_BUT_LICENSED` | CSV flags column | Met |
| 5 | Privileged roles identified and reviewed | Export flags `PRIVILEGED` | CSV flags column | Met |
| 6 | Stale accounts identified | 90-day no-sign-in flag | CSV flags column | Met |
| 7 | Identity changes are reviewable | Infrastructure as code with history | Git log | Met |
| 8 | Automation credentials expire | 30-day secret on the app registration | `automation.tf` | Met |
| 9 | MFA required for all users | Not configured in this lab | — | **Not met** |
| 10 | Access reviews run on a schedule | Script exists, no schedule yet | — | **Not met** |

## Remediation
| # | Gap | Fix | Owner | Target |
|---|---|---|---|---|
| 9 | No MFA policy | Conditional Access requiring MFA, rolled out in report-only first | Me | Next sprint |
| 10 | Reviews are manual | Schedule the export monthly, store output with timestamps | Me | Next sprint |