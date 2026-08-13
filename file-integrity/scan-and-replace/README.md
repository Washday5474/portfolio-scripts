# Scan and Replace

Recursively scans a drive for a target file and, if found, deletes it and replaces it with a specified source file. Logs every action taken.

## Usage
Edit the variables at the top of the script:
- `$sourceDrive` — drive to scan (e.g. `C:\`)
- `$targetFile` — filename to search for
- `$replacementFile` — path to the replacement file
- `$logFile` — where to write the action log

**Must be run as Administrator** to generate the log and have file system permissions to delete/replace matched files.

```powershell
.\ScanAndReplace.ps1
```
