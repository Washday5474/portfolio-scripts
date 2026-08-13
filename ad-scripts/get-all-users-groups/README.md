# AD Users & Groups Export

Exports every AD user and every AD group in the domain to CSV for inventory/audit purposes.

## Usage
Run in a PowerShell session with the ActiveDirectory module (RSAT) installed and sufficient read permissions:
```powershell
.\AD-UsersAndGroups.ps1
```
Outputs `C:\temp\ADUsers.csv` and `C:\temp\ADGroups.csv`. Adjust the export paths in the script as needed.
