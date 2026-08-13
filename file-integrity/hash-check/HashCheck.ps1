$FilePath = 'C:\PATH\TO\FILE.txt' # Change path to desired file
$KnownGoodHash = 'EnterHashHere' # Enter validated hash from vendor here
$ChecksumAlgorithm = 'SHA256' # Change algorithm here if required to match known good hash value

if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

try {
    $FileHash = Get-FileHash -Algorithm $ChecksumAlgorithm -Path $FilePath -ErrorAction Stop
} catch {
    Write-Error "Failed to compute hash for '$FilePath': $_"
    exit 1
}

if ($FileHash.Hash -eq $KnownGoodHash) {
    Write-Host 'File hash matches known good hash.'
} else {
    Write-Host 'File hash does NOT match known good hash!'
}
