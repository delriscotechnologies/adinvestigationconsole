<h1 align="center">Active Directory Investigation Console</h1>

<p align="center">
  A local PowerShell utility for fast, read-only Active Directory lookups.
</p>

---

Active Directory Investigation Console is one Windows PowerShell 5.1 script with a WPF interface for three common investigation tasks: user lookup, device lookup, and AD group lookup.

The console performs exact, read-only queries using the current Windows and Active Directory security context, then presents the selected result in one place for review or copying.

> Use the console only in Active Directory environments you own or are explicitly authorized to investigate.

## Quick Start

You need a domain-connected Windows host with Windows PowerShell 5.1, the RSAT Active Directory module, network access to Active Directory, and permission to read the requested objects.

```powershell
git clone https://github.com/delriscotechnologies/adinvestigationconsole.git
cd adinvestigationconsole
powershell.exe -File .\ADInvestigationConsole.ps1
```

If your organization restricts PowerShell execution, follow its approved execution-policy and code-signing requirements.

## What You Get

| Lookup | Input | Result |
| --- | --- | --- |
| User | Exact user ID or email | User ID, department, email, and OU path |
| Device | Exact computer name | Computer name, possible department inferred from OU, full OU path, and Distinguished Name |
| AD Group | Exact AD group identity | Full group Distinguished Name |

The **Copy Result** button copies successful output to the clipboard.

## How Lookups Work

The script uses the current Windows and Active Directory security context. It does not store or request credentials.

Each search expects an exact identity rather than a broad discovery query. `Possible Department` in the device result is inferred from the computer's OU structure and should be treated as a convenience value, not an authoritative Active Directory department attribute.

## Safety and Privacy

- Performs Active Directory read operations only.
- Does not create, modify, delete, or move users, computers, groups, or OUs.
- Does not collect or handle separate credentials.
- Returns directory information that may be sensitive and should be handled according to your organization's access and retention requirements.

See [SECURITY.md](SECURITY.md) for security and vulnerability-reporting guidance.

## License

Active Directory Investigation Console is available under the [MIT License](LICENSE).
