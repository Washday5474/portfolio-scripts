# Import the Active Directory module for the Get-ADUser cmdlet
Import-Module ActiveDirectory

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Specify enabled status
$status = $true # Change TRUE or FALSE as necessary

# Get the users from AD
$users = Get-ADUser -Filter {(Enabled -eq $status) -and (SamAccountName -like "*pdc")}

# Define the data to export
$dataToExport = $users | Select-Object SamAccountName, Name, Enabled, UserPrincipalName

# Export the data to a CSV file
$dataToExport | Export-Csv -Path C:\temp\PDC_ADUsers.csv -NoTypeInformation # Change path if necessary
