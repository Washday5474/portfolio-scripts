try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Error "Failed to load the ActiveDirectory module. Ensure RSAT/AD PowerShell tools are installed. $_"
    exit 1
}

try {
    Get-ADUser -Filter * -ErrorAction Stop | Export-Csv -Path C:\temp\ADUsers.csv -NoTypeInformation
    Get-ADGroup -Filter * -ErrorAction Stop | Export-Csv -Path C:\temp\ADGroups.csv -NoTypeInformation
    Write-Host "Export complete: C:\temp\ADUsers.csv and C:\temp\ADGroups.csv"
} catch {
    Write-Error "AD query or export failed: $_"
    exit 1
}
