$subnetFile = "subnets.txt"
$outputFile = "raw_nmap_scan.txt"

# Ensure nmap is installed
if (!(Get-Command "nmap" -ErrorAction SilentlyContinue)) {
    Write-Host "Nmap is not installed."
    exit 1
}

# Ensure the subnet list exists
if (-not (Test-Path -Path $subnetFile -PathType Leaf)) {
    Write-Error "Subnet file not found: $subnetFile"
    exit 1
}

# Read the subnets from the file and run nmap
Get-Content $subnetFile | ForEach-Object {
    try {
        # Run nmap
        Write-Host "Scanning $_..."
        nmap --script ssl-enum-ciphers,sslv2 -p- --open $_ -oN $outputFile --append-output
    } catch {
        Write-Error "Nmap scan failed for $_ : $_"
    }
}

Write-Host "Scan(s) complete. Results stored in $outputFile"
