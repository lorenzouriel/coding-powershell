# Define Backup Paths and Destination URL
$backupPath = "C:\Backup\WIN-NAME"
$includePaths = @("project1\FULL", "project2\FULL", "project3\FULL", "project4\FULL")
$destinationBaseURL = "https://backup.blob.core.windows.net/backups"

# Initialize an Array to Store Latest Backup File Details
$latestBackups = @()

# Iterate Through Each Backup Directory
foreach ($path in $includePaths) {
    $fullPath = Join-Path -Path $backupPath -ChildPath $path
    
    # Check If Directory Exists
    if (Test-Path $fullPath) {
        Write-Host "Checking path: $fullPath"
        
        # Retrieve the Most Recent .bak File
        $latestFile = Get-ChildItem -Path $fullPath -Filter "*.bak" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        
        # Store the Latest Backup File Information
        if ($latestFile) {
            Write-Host "Found: $($latestFile.FullName)"
            $latestBackups += [PSCustomObject]@{
                FullPath = $latestFile.FullName
                BlobPath = "$path/$($latestFile.Name)" 
            }
        } else {
            Write-Host "No .bak file found in $fullPath"
        }
    } else {
        Write-Host "Path does not exist: $fullPath"
    }
}

# Display the Selected Backup Files
Write-Host "`nLatest backups from each path:"
$latestBackups | ForEach-Object { Write-Output $_.FullPath }

# Upload Backup Files to Azure Blob Storage Using AzCopy
foreach ($file in $latestBackups) {
    $fileURL = "$destinationBaseURL/$($file.BlobPath)?sp=TOKEN"
    Write-Host "Uploading: $($file.FullPath) to $fileURL"
    
    & "c:\tools\azcopy\azcopy.exe" copy "$($file.FullPath)" "$fileURL" --overwrite=false --cap-mbps 250
}