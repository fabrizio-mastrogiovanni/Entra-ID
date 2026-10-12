# Runbook: Employee Onboarding and Offboarding

## Onboarding
| # | Step | Command / location | Verify |
|---|---|---|---|
| 1 | Create user | Terraform `azuread_user` | `Get-MgUser -UserId <upn>` |
| 2 | Add to licensing group | Terraform `azuread_group_member` | License appears within ~2 min |
| 3 | Add to access groups | Terraform | `Get-MgUserMemberOf` |
| 4 | Confirm mailbox | `Get-Mailbox <upn>` | Mailbox exists |
| 5 | Confirm MFA enrolled | Entra admin center | Methods registered |
| 6 | Record completion | Ticket | Date and ticket number |

## Offboarding
Order matters. Do not reorder steps 4 and 5.

| # | Step | Command | Why this order |
|---|---|---|---|
| 1 | Block sign-in | `Update-MgUser -AccountEnabled:$false` | Stops new sign-ins |
| 2 | Revoke sessions | `Revoke-MgUserSignInSession` | Step 1 does not kill a live session |
| 3 | Remove from groups | `Remove-MgGroupMemberByRef` | Group membership granted the access |
| 4 | Convert mailbox to shared | `Set-Mailbox -Type Shared` | Preserves the data |
| 5 | Confirm license released | `Get-MgUserLicenseDetail` | Frees the seat |
| 6 | Transfer file ownership | SharePoint admin center | Files outlive the person |
| 7 | Record date | Ticket + log | This is the audit evidence |

## Known failure modes
- Group-based licensing fails silently when the tenant runs out of seats. Check `Get-MgSubscribedSku` before onboarding.
- Dynamic group membership is not instant. Access can linger after the rule should have removed it.
- Removing the license before converting the mailbox starts a 30-day deletion clock on the data.