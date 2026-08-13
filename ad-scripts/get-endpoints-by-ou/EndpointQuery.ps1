# Set the name of the OU to retrieve devices from
$ouName = "Laptops" # Change OU here
$exportFile = "C:\temp\AD_Computers.csv" # Change export file name and path here
$status = $true # Change flag to TRUE or FALSE as necessary

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Retrieve all enabled devices from the specified OU
Get-ADComputer -SearchBase "OU=$ouName,DC=example,DC=local" -Filter {Enabled -eq $status} | Select-Object Name, Enabled | Export-Csv -NoTypeInformation -Path $exportFile
