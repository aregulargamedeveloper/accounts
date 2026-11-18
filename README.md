# Proxy account registry

This repository is the owner-managed allowlist for the account-gated proxy packages. Users do not self-register. Only the repository owner (or a collaborator explicitly granted write access) can publish additions or revocations to `accounts.json`. Keep the account-management scripts in your owner working copy; users only need the registry data and configured proxy packages.

## Create and revoke accounts

Double-click `New-ProxyAccount.bat` from the USB or an existing clone. If needed, it clones the owner account manager automatically. Enter a username; it generates a five-character password and stores only its SHA-256 hash in `accounts.json`. Press Enter when asked to publish, and the script commits and pushes the registry for you. Give the username and password to the user privately. Users do not receive write access. Git for Windows is required.

If you type `N` at the publish prompt, the account stays local until you commit and push the changed `accounts.json` yourself.

```powershell
New-ProxyAccount.bat
```

To revoke an account, double-click `Revoke-ProxyAccount.bat` in the clone. It asks for the username and requires you to type `REVOKE <username>` before removing the entry. Commit and push the changed `accounts.json` to make the revocation active. You can also run `Revoke-ProxyAccount.ps1` directly. The proxy launchers check the registry each time they start and fail closed if GitHub cannot be reached.

Use nicknames rather than real names because usernames are visible in a public registry. New passwords are five random characters using letters and digits that are easy to distinguish. They are intentionally short for convenience; do not reuse them for other services. Existing longer account keys continue to work.

## Configure client packages

The client `account-settings.json` is already configured to read this repository's raw registry:

`https://raw.githubusercontent.com/aregulargamedeveloper/accounts/main/accounts.json`

Do not put a GitHub access token in a proxy package. The client only needs public read access. The repository stores usernames and hashes of random keys, never the keys themselves.

## Security limits

This is an owner-managed client-side gate for casual access control. A user who can edit the local PowerShell files or directly run the bundled Wireproxy can bypass it. Strong enforcement requires unique VPN credentials or an authentication service at the proxy server; a GitHub file alone cannot secure a proxy credential embedded on a user's PC.
