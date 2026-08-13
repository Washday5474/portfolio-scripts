# AD Users by Naming Convention

Two companion scripts that pull AD users whose `SamAccountName` matches a naming convention (e.g. accounts ending in `grp` or `pdc`), plus a Python wrapper (`Combo.py`) that runs both in sequence.

## Usage
```
python Combo.py
```
Or run each `.ps1` independently. Customize:
- `$domainController` — target server (GRPQuery.ps1 only)
- `$status` — enabled/disabled filter
- The `-like` wildcard pattern to match your own naming convention
