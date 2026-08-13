# Import the Active Directory module for the Get-ADUser cmdlet
Import-Module ActiveDirectory

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Specify the domain controller
$OU = "DC=example,DC=local"

# Specify enabled status
$status = $true # Change TRUE or FALSE as necessary

# Get the users from AD
$device = Get-ADComputer -Server $OU -Filter {(Enabled -eq $status)}

# Define the data to export
$dataToExport = $device | Select-Object Name, Enabled

# Export the data to a CSV file
$dataToExport | Export-Csv -Path C:\temp\AD-Enabled-Servers.csv -NoTypeInformation
