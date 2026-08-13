# Import the Active Directory module for the Get-ADUser cmdlet
Import-Module ActiveDirectory

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Specify the domain controller
$domainController = "dc01.example.local" # Change server/DC if necessary

# Specify enabled status
$status = $true # Change TRUE or FALSE as necessary

# Get the users from AD
$users = Get-ADUser -Server $domainController -Filter {(Enabled -eq $status) -and (SamAccountName -like "*grp")}

# Define the data to export
$dataToExport = $users | Select-Object SamAccountName, Name, Enabled, UserPrincipalName

# Export the data to a CSV file
$dataToExport | Export-Csv -Path C:\temp\GRP_ADUsers.csv -NoTypeInformation # Change path if necessary
