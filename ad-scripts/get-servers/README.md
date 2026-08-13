# AD Server Pull

Retrieves all enabled (or disabled) computer objects from the domain and exports them to CSV.

## Usage
```powershell
.\Server_Pull.ps1
```
Replace `dc01.example.local` with your own domain controller's hostname, and adjust `$status` for enabled/disabled devices.
