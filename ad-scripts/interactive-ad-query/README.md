# Interactive AD Query

A small Python wrapper that prompts for search criteria (enabled/disabled, username pattern, target server) and dynamically generates + runs a `Get-ADUser` PowerShell query, exporting results to CSV. The generated `.ps1` file is deleted after execution so no query artifacts are left behind.

## Usage
```
python interactive_ADQuery.py
```
You'll be prompted for:
- Account status: `enabled` or `disabled`
- Username pattern (wildcards supported, e.g. `*svc`)
- Output CSV filename
- Target AD server (optional — replace with your own domain controller hostname)

## Notes
- Requires the RSAT Active Directory PowerShell module on the host running the script.
- All server names, domains, and paths in this repo are placeholders — swap in your own environment's values before running.
