# Security Policy

## Supported Version

Security fixes are applied to the latest version on the `main` branch.

## Reporting a Vulnerability

Use GitHub private vulnerability reporting from the repository's **Security** tab when available. Do not post credentials, internal domain information, sensitive Distinguished Names, or other private Active Directory data in a public issue.

Include the affected version, reproduction steps, expected behavior, actual behavior, and potential impact.

## Security Model

AD Investigation Console is intentionally read-only. It uses `Get-ADUser`, `Get-ADComputer`, and `Get-ADGroup` and does not perform Active Directory write operations.

The script:

- uses the current Windows/AD security context
- does not store or request passwords or tokens
- loads the ActiveDirectory module from the standard Windows PowerShell module path
- does not use `Invoke-Expression` or construct shell commands from lookup input
- copies successful lookup results to the Windows clipboard only when requested

## Operational Guidance

Run the tool only from trusted Windows systems and only against Active Directory environments you are authorized to access.

Treat lookup results as potentially sensitive directory information. Clipboard contents may remain available to other local applications after using **Copy Result**.

The device `Possible Department` value is inferred from the OU hierarchy and is not an authoritative `Department` attribute.
