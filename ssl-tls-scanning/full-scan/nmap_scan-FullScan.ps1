$subnetFile = "subnets.txt"
$outputFile = "raw_nmap_scan.txt"

# Ensure nmap is installed
if (!(Get-Command "nmap" -ErrorAction SilentlyContinue)) {
    Write-Host "Nmap is not installed."
    exit
}

# Read the subnets from the file and run nmap
Get-Content $subnetFile | ForEach-Object {
    # Run nmap
    Write-Host "Scanning $_..."
    nmap --script ssl-enum-ciphers,sslv2 -p- --open $_ -oN $outputFile --append-output
}

Write-Host "Scan(s) complete. Results stored in $outputFile"
