# PowerShell script to scan a drive for a file, delete, and replace

# Define variables
$sourceDrive = "C:\" # Set the drive to scan
$targetFile = "marco.txt" # Set the file name to search for
$replacementFile = "polo.txt" # Set the replacement file path
$logFile = "C:\temp\file_replace_logFile.txt" # Set the log file name and path

# Create temp folder for output file
New-Item -Path 'C:\temp\' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

# Find the file in the specified drive
$foundFiles = Get-ChildItem -Path $sourceDrive -Recurse -Filter $targetFile -ErrorAction SilentlyContinue

# Check if the file is found and perform the replacement
if ($foundFiles) {
    foreach ($foundFile in $foundFiles) {
        $logMessage = "Found file: $($foundFile.FullName)"
        Write-Host $logMessage
        $logMessage | Out-File -FilePath $logFile -Append

        # Delete the original file
        Remove-Item $foundFile.FullName

        # Copy the replacement file to the original file's location
        Copy-Item $replacementFile -Destination $foundFile.Directory.FullName -Force

        $logMessage = "File replaced successfully"
        Write-Host $logMessage
        $logMessage | Out-File -FilePath $logFile -Append
    }
} else {
    $logMessage = "File not found"
    Write-Host $logMessage
    $logMessage | Out-File -FilePath $logFile -Append
}
