# Active Directory Investigation Console

A small Windows PowerShell 5.1 + WPF utility for fast, read-only Active Directory lookups.

The console keeps three common investigation tasks in one GUI: user lookup, device lookup, and AD group lookup.

## Requirements

- Windows PowerShell 5.1
- RSAT / Microsoft ActiveDirectory PowerShell module
- Network access to Active Directory
- An account with permission to read the requested AD objects

The script uses the current Windows/AD security context. It does not store or request credentials.

## Quick Start

```powershell
git clone https://github.com/delriscotechnologies/adinvestigationconsole.git
cd adinvestigationconsole
powershell.exe -File .\ADInvestigationConsole.ps1
```

If your organization restricts PowerShell execution, follow its approved execution-policy and code-signing requirements.

## Lookups

| Lookup | Input | Result |
| --- | --- | --- |
| User | Exact user ID or email | User ID, department, email, and OU path |
| Device | Exact computer name | Computer name, possible department inferred from OU, full OU path, and Distinguished Name |
| AD Group | Exact AD group identity | Full group Distinguished Name |

The **Copy Result** button copies successful output to the clipboard.

## Scope

This utility performs Active Directory read operations only. It does not create, modify, delete, or move users, computers, groups, or OUs.

`Possible Department` in the device result is inferred from the computer's OU structure and should be treated as a convenience value, not an authoritative AD department attribute.

Use the tool only in Active Directory environments you are authorized to access.

See [SECURITY.md](SECURITY.md) for security and vulnerability-reporting guidance.

## License

Licensed under the [MIT License](LICENSE).
