<#
.SYNOPSIS
  Exports every user with groups, licenses, roles, and last sign-in.
  Flags accounts that are disabled but still licensed, and accounts
  with no sign-in in the last 90 days.
.NOTES
  Produces access review evidence for a SOC 2 audit period.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "./output",
    [int]$StaleDays = 90
)

$ErrorActionPreference = 'Stop'

# Fail early with a clear message rather than a confusing one later
if (-not (Get-MgContext)) {
    throw "Not connected. Run: Connect-MgGraph -Scopes 'User.Read.All','Group.Read.All','Directory.Read.All','AuditLog.Read.All'"
}

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
$stamp  = Get-Date -Format 'yyyy-MM-dd-HHmm'
$cutoff = (Get-Date).AddDays(-$StaleDays)

Write-Host "Collecting users..."

# -All matters. Without it you get the first page only and your
# "complete" user list silently is not.
$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,AccountEnabled,CreatedDateTime,SignInActivity

$rows = foreach ($u in $users) {

    $licenses = (Get-MgUserLicenseDetail -UserId $u.Id -ErrorAction SilentlyContinue).SkuPartNumber

    $groups = (Get-MgUserMemberOf -UserId $u.Id -All | Where-Object {
        $_.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.group'
    }).AdditionalProperties.displayName

    $roles = (Get-MgUserMemberOf -UserId $u.Id -All | Where-Object {
        $_.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.directoryRole'
    }).AdditionalProperties.displayName

    $lastSignIn = $u.SignInActivity.LastSignInDateTime

    $flags = @()
    if (-not $u.AccountEnabled -and $licenses) { $flags += 'DISABLED_BUT_LICENSED' }
    if ($lastSignIn -and $lastSignIn -lt $cutoff) { $flags += 'STALE_SIGNIN' }
    if (-not $lastSignIn) { $flags += 'NEVER_SIGNED_IN' }
    if ($roles) { $flags += 'PRIVILEGED' }

    [PSCustomObject]@{
        DisplayName       = $u.DisplayName
        UserPrincipalName = $u.UserPrincipalName
        Enabled           = $u.AccountEnabled
        Created           = $u.CreatedDateTime
        LastSignIn        = $lastSignIn
        Licenses          = ($licenses -join '; ')
        Groups            = ($groups   -join '; ')
        DirectoryRoles    = ($roles    -join '; ')
        Flags             = ($flags    -join '; ')
    }
}

$file = Join-Path $OutputPath "access-review-$stamp.csv"
$rows | Sort-Object DisplayName | Export-Csv -Path $file

Write-Host ""
Write-Host "Users:              $($rows.Count)"
Write-Host "Disabled, licensed: $(($rows | Where-Object Flags -match 'DISABLED_BUT_LICENSED').Count)"
Write-Host "Stale sign-in:      $(($rows | Where-Object Flags -match 'STALE_SIGNIN').Count)"
Write-Host "Privileged:         $(($rows | Where-Object Flags -match 'PRIVILEGED').Count)"
Write-Host ""
Write-Host "Written to $file"