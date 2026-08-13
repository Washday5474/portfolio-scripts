Import-Module ActiveDirectory
Get-ADUser -Filter * | Export-Csv -Path C:\temp\ADUsers.csv -NoTypeInformation
Get-ADGroup -Filter * | Export-Csv -Path C:\temp\ADGroups.csv -NoTypeInformation
