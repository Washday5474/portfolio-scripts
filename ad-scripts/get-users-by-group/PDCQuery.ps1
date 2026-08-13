# Import the Active Directory module for the Get-ADUser cmdlet
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to load the ActiveDirectory module. Ensure RSAT/AD PowerShell tools are installed. $_"
    exit 1
}

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Specify enabled status
$status = $true # Change TRUE or FALSE as necessary

# Get the users from AD, and export to a CSV file
try {
    $users = Get-ADUser -Filter {(Enabled -eq $status) -and (SamAccountName -like "*pdc")} -ErrorAction Stop
    $dataToExport = $users | Select-Object SamAccountName, Name, Enabled, UserPrincipalName
    $dataToExport | Export-Csv -Path C:\temp\PDC_ADUsers.csv -NoTypeInformation # Change path if necessary
    Write-Host "Export complete: C:\temp\PDC_ADUsers.csv"
} catch {
    Write-Error "AD query or export failed: $_"
    exit 1
}
