# Proxy account registry

This repository is the owner-managed allowlist for the account-gated proxy packages. Users do not self-register. Only the repository owner (or a collaborator explicitly granted write access) can publish additions or revocations to `accounts.json`. Keep the account-management scripts in your owner working copy; users only need the registry data and configured proxy packages.

## Create and revoke accounts

Clone this repository to the owner's PC, then run `New-ProxyAccount.ps1` from that clone. It generates a random one-time account key and stores only its SHA-256 hash in `accounts.json`. Give the key to that user privately; the key is not recoverable from the repository. Commit and push the changed `accounts.json` to activate the account. Users do not receive write access.

```powershell
git clone https://github.com/aregulargamedeveloper/accounts.git
cd accounts
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\New-ProxyAccount.ps1
git add accounts.json
git commit -m "Add proxy account"
git push
```

Run `Revoke-ProxyAccount.ps1` from the clone to remove an account. Commit and push `accounts.json` to revoke it. The proxy launchers check the registry each time they start and fail closed if GitHub cannot be reached.

Use nicknames rather than real names because usernames are visible in a public registry. The account keys are generated from 256 bits of randomness; do not replace them with human-chosen passwords.

## Configure client packages

The client `account-settings.json` is already configured to read this repository's raw registry:

`https://raw.githubusercontent.com/aregulargamedeveloper/accounts/main/accounts.json`

Do not put a GitHub access token in a proxy package. The client only needs public read access. The repository stores usernames and hashes of random keys, never the keys themselves.

## Security limits

This is an owner-managed client-side gate for casual access control. A user who can edit the local PowerShell files or directly run the bundled Wireproxy can bypass it. Strong enforcement requires unique VPN credentials or an authentication service at the proxy server; a GitHub file alone cannot secure a proxy credential embedded on a user's PC.

