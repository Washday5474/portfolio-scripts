# AD Endpoints by OU

Retrieves enabled/disabled endpoints from a chosen Organizational Unit (OU).

## Usage
Edit the variables at the top of `EndpointQuery.ps1`:
- `$ouName` — the OU to query (e.g. `Laptops`)
- `$exportFile` — output CSV path
- `$status` — `$true` for enabled devices, `$false` for disabled

Then run:
```powershell
.\EndpointQuery.ps1
```

Replace `DC=example,DC=local` in the `-SearchBase` parameter with your own domain's distinguished name.
