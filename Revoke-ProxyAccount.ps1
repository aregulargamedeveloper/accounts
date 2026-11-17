$ErrorActionPreference = 'Stop'
$registryPath = Join-Path $PSScriptRoot 'accounts.json'
if (-not (Test-Path -LiteralPath $registryPath)) { throw "Registry file is missing: $registryPath" }

$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
if ([int]$registry.schemaVersion -ne 1) { throw 'Unsupported account registry schema.' }
$username = (Read-Host 'Account username to revoke').Trim()
$matches = @($registry.accounts | Where-Object { $_.username -ieq $username })
if ($matches.Count -eq 0) { throw "Account '$username' was not found." }
$confirm = Read-Host "Type REVOKE $username to remove this account"
if ($confirm -cne "REVOKE $username") { Write-Host 'Cancelled.'; exit 0 }

$registry.accounts = @($registry.accounts | Where-Object { $_.username -ine $username })
$temporary = "$registryPath.tmp"
$json = $registry | ConvertTo-Json -Depth 5
[IO.File]::WriteAllText($temporary, $json + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
Move-Item -LiteralPath $temporary -Destination $registryPath -Force
Write-Host "Removed '$username'. Commit and push accounts.json to revoke access." -ForegroundColor Green

