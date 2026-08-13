# SSL/TLS Port-Specific Scan

Same idea as the full scan, but for a targeted list of `IP:port` pairs — useful when you already know which services need checking instead of sweeping every port. Results are parsed into an Excel file for easier filtering/reporting.

## Usage
1. List `IP:port1,port2` pairs in `subnets_WithPorts.txt` (sample placeholder values from the RFC 5737 documentation range are included).
2. Run the scan:
   ```powershell
   .\nmap_scan_PortSpecific.ps1
   ```
3. Parse the results:
   ```
   python parse_results_PortSpecific.py
   ```
   This produces `cleaned_nmap_scan_PortSpecific.xlsx`. A sample of the expected output is in `cleaned_nmap_scan_PortSpecific.example.xlsx`.

## Requirements
- [Nmap](https://nmap.org/) installed and on PATH
- PowerShell
- Python with `pandas` and `openpyxl`

## Notes
- Update `PS_FILE_PATH` in `parse_results_PortSpecific.py` to match where you place this script.
