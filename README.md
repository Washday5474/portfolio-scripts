# Security & IT Automation Scripts

A collection of PowerShell and Python scripts written to automate common Active Directory administration, file integrity verification, and SSL/TLS configuration auditing tasks.

All environment-specific values (domain names, server names, internal IP addresses, and file paths) have been replaced with generic placeholders or RFC 5737 documentation-range sample IPs. Swap in your own environment's values before running any of these.

## Contents

### `ad-scripts/`
- **interactive-ad-query** — Python-driven interactive prompt that builds and runs an ad hoc `Get-ADUser` query.
- **get-all-users-groups** — Exports every AD user and group to CSV.
- **get-endpoints-by-ou** — Exports enabled/disabled computer objects from a chosen OU.
- **get-users-by-group** — Pulls AD users matching a naming convention, with a Python runner for batch execution.
- **get-servers** — Exports all AD computer objects domain-wide.

### `file-integrity/`
- **hash-check** — Verifies a file's hash against a known-good value.
- **scan-and-replace** — Recursively finds and replaces a target file across a drive, with logging.

### `ssl-tls-scanning/`
- **full-scan** — Nmap-based SSL/TLS protocol and cipher enumeration across a list of subnets, parsed into a clean report.
- **port-specific** — Same scan logic targeted at specific `IP:port` pairs, output to Excel for easier review.

## Disclaimer
These scripts were written for internal IT/security operations and have been sanitized for public sharing. Test in a non-production environment before use. Nmap scanning scripts should only be run against systems you own or have explicit authorization to test.
