# Set the name of the OU to retrieve devices from
$ouName = "Laptops" # Change OU here
$exportFile = "C:\temp\AD_Computers.csv" # Change export file name and path here
$status = $true # Change flag to TRUE or FALSE as necessary

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to load the ActiveDirectory module. Ensure RSAT/AD PowerShell tools are installed. $_"
    exit 1
}

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Retrieve all enabled devices from the specified OU
try {
    Get-ADComputer -SearchBase "OU=$ouName,DC=example,DC=local" -Filter {Enabled -eq $status} -ErrorAction Stop | Select-Object Name, Enabled | Export-Csv -NoTypeInformation -Path $exportFile
    Write-Host "Export complete: $exportFile"
} catch {
    Write-Error "AD query or export failed. Check that OU '$ouName' exists and is reachable: $_"
    exit 1
}
