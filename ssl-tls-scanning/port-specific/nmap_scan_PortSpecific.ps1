$ipFile = "subnets_WithPorts.txt"
$outputFile = "raw_nmap_scan.txt"

# Ensure nmap is installed
if (!(Get-Command "nmap" -ErrorAction SilentlyContinue)) {
    Write-Host "Nmap is not installed."
    exit 1
}

# Ensure the IP:port list exists
if (-not (Test-Path -Path $ipFile -PathType Leaf)) {
    Write-Error "IP:port file not found: $ipFile"
    exit 1
}

# Read the IPs with ports from the file and run nmap
Get-Content $ipFile | ForEach-Object {
    $line = $_

    if ($line -notmatch ":") {
        Write-Warning "Skipping malformed line (expected IP:port): $line"
        return
    }

    $ip = $line.split(":")[0]
    $ports = $line.split(":")[1] -split ","

    # Run nmap for each port
    foreach ($port in $ports) {
        try {
            # Run nmap
            Write-Host "Scanning $ip on port $port..."
            nmap --script ssl-enum-ciphers,sslv2 -p $port $ip -oN $outputFile --append-output
        } catch {
            Write-Error "Nmap scan failed for $ip`:$port : $_"
        }
    }
}

Write-Host "Scan(s) complete. Results stored in $outputFile"
