$ErrorActionPreference = 'Stop'
$registryPath = Join-Path $PSScriptRoot 'accounts.json'

if (-not (Test-Path -LiteralPath $registryPath)) {
    throw "Registry file is missing: $registryPath"
}

$username = (Read-Host 'New account username (3-32 letters, numbers, ., _, or -)').Trim()
if ($username -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{2,31}$') {
    throw 'Use 3-32 characters: letters, numbers, dot, underscore, or dash; start with a letter or number.'
}

$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
if ([int]$registry.schemaVersion -ne 1) { throw 'Unsupported account registry schema.' }
if (@($registry.accounts | Where-Object { $_.username -ieq $username }).Count -gt 0) {
    throw "An account named '$username' already exists."
}

$randomBytes = New-Object byte[] 5
$rng = [Security.Cryptography.RandomNumberGenerator]::Create()
try { $rng.GetBytes($randomBytes) } finally { $rng.Dispose() }
$alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
$key = -join @($randomBytes | ForEach-Object { $alphabet[[int]$_ % $alphabet.Length] })
[Array]::Clear($randomBytes, 0, $randomBytes.Length)
$sha = [Security.Cryptography.SHA256]::Create()
try { $hash = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($key))).Replace('-', '').ToLowerInvariant() } finally { $sha.Dispose() }

$registry.accounts += [pscustomobject]@{
    username  = $username
    tokenHash = $hash
    createdUtc = [DateTime]::UtcNow.ToString('o')
}
$json = $registry | ConvertTo-Json -Depth 5
$temporary = "$registryPath.tmp"
[IO.File]::WriteAllText($temporary, $json + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
Move-Item -LiteralPath $temporary -Destination $registryPath -Force

Write-Host ''
Write-Host 'Account added to the local registry.' -ForegroundColor Green
Write-Host "Username: $username"
Write-Host "5-character password (shown only now): $key" -ForegroundColor Yellow
Write-Host ''
Write-Host 'Give the password to the user privately. Commit and push accounts.json to activate the account.'
Write-Host 'The repository stores only its SHA-256 hash, never the password.'
