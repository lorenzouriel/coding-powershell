$backupFolder = "C:\Backup\WIN-NAME\"  # Specify the backup folder
$daysOld = 7  # Delete files older than 7 days

# Get all .bak files in the folder and subfolders
$backups = Get-ChildItem $backupFolder -Recurse -Include "*.bak"

# Filter files older than the specified days
$oldBackups = $backups | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$daysOld)}

# Delete the files
foreach ($backup in $oldBackups) {
    Write-Host "Deleting: $($backup.FullName)"
    Remove-Item $backup.FullName -Force
}

Write-Host "Old .bak files deleted."