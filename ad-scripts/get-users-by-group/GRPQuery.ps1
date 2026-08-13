# Import the Active Directory module for the Get-ADUser cmdlet
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to load the ActiveDirectory module. Ensure RSAT/AD PowerShell tools are installed. $_"
    exit 1
}

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Specify the domain controller
$domainController = "dc01.example.local" # Change server/DC if necessary

# Specify enabled status
$status = $true # Change TRUE or FALSE as necessary

# Get the users from AD, and export to a CSV file
try {
    $users = Get-ADUser -Server $domainController -Filter {(Enabled -eq $status) -and (SamAccountName -like "*grp")} -ErrorAction Stop
    $dataToExport = $users | Select-Object SamAccountName, Name, Enabled, UserPrincipalName
    $dataToExport | Export-Csv -Path C:\temp\GRP_ADUsers.csv -NoTypeInformation # Change path if necessary
    Write-Host "Export complete: C:\temp\GRP_ADUsers.csv"
} catch {
    Write-Error "AD query or export failed. Check that '$domainController' is reachable: $_"
    exit 1
}
