# SSL/TLS Full Scan

Runs an Nmap SSL/TLS cipher and protocol enumeration scan (`ssl-enum-ciphers`, `sslv2`) across all ports for every host/subnet listed in `subnets.txt`, then parses the raw output into a clean per-host, per-port breakdown of which SSL/TLS versions are enabled.

## Usage
1. List target IPs/subnets in `subnets.txt` (one per line — sample placeholder values from the RFC 5737 documentation range are included).
2. Run the scan:
   ```powershell
   .\nmap_scan-FullScan.ps1
   ```
3. Parse the results:
   ```
   python parse_results-FullScan.py
   ```
   This produces `cleaned_nmap_scan.txt`. A sample of the expected output format is in `cleaned_nmap_scan.example.txt`.

## Requirements
- [Nmap](https://nmap.org/) installed and on PATH
- PowerShell

## Notes
- Update `PS_FILE_PATH` in `parse_results-FullScan.py` to match where you place this script.
- Findings like SSLv2/TLS 1.0/1.1 support indicate deprecated protocol versions that should be disabled per current hardening guidance (e.g. PCI DSS, NIST SP 800-52).
