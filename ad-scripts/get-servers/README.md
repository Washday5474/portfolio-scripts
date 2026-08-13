# AD Server Pull

Retrieves all enabled (or disabled) computer objects from the domain and exports them to CSV.

## Usage
```powershell
.\Server_Pull.ps1
```
Replace `DC=example,DC=local` with your own domain's distinguished name, and adjust `$status` for enabled/disabled devices.
