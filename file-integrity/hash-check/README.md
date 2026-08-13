# File Hash Check

Generates a hash for a given file and compares it against a known-good hash (e.g. one published by a vendor) to verify file integrity.

## Usage
Edit the variables before running:
- `$FilePath` — path to the file to check
- `$KnownGoodHash` — the trusted hash value to compare against
- `$ChecksumAlgorithm` — defaults to `SHA256`; change if the known-good hash uses a different algorithm

```powershell
.\HashCheck.ps1
```
