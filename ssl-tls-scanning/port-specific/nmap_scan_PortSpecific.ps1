$ipFile = "subnets_WithPorts.txt"
$outputFile = "raw_nmap_scan.txt"

# Ensure nmap is installed
if (!(Get-Command "nmap" -ErrorAction SilentlyContinue)) {
    Write-Host "Nmap is not installed."
    exit
}

# Read the IPs with ports from the file and run nmap
Get-Content $ipFile | ForEach-Object {
    $line = $_
    $ip = $line.split(":")[0]
    $ports = $line.split(":")[1] -split ","
    
    # Run nmap for each port
    foreach ($port in $ports) {
        # Run nmap
        Write-Host "Scanning $ip on port $port..."
        nmap --script ssl-enum-ciphers,sslv2 -p $port $ip -oN $outputFile --append-output
    }
}

Write-Host "Scan(s) complete. Results stored in $outputFile"
