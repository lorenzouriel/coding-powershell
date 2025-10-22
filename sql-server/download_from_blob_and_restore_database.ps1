# ==============================
# CONFIGURATION
# ==============================
$storageAccountName = "yourstorageaccount"
$containerName      = "backups"
$storageKey         = "your_storage_account_key"
$downloadPath       = "C:\Temp\latest_backup.bak"

$sqlServerInstance  = "localhost"           # or "SERVER\INSTANCE"
$databaseName       = "YourDatabaseName"
$restoreDataPath    = "C:\SQLData\"         # Folder for .mdf and .ldf
# ==============================

Write-Host "Connecting to Azure Storage..."

# Create storage context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

Write-Host "Getting the latest .bak file..."
$blobs = Get-AzStorageBlob -Container $containerName -Context $ctx | Where-Object { $_.Name -like "*.bak" }

# Sort by LastModified descending and pick the newest
$latestBlob = $blobs | Sort-Object -Property LastModified -Descending | Select-Object -First 1

if ($null -eq $latestBlob) {
    Write-Error "❌ No .bak files found in container '$containerName'"
    exit
}

Write-Host "📦 Downloading latest backup: $($latestBlob.Name)"
Get-AzStorageBlobContent -Blob $latestBlob.Name -Container $containerName -Destination $downloadPath -Context $ctx -Force

# Import SQL module
Import-Module SqlServer

# ==============================
# CHECK AND REMOVE EXISTING DATABASE
# ==============================
Write-Host "🔍 Checking if database '$databaseName' exists..."

$dbExistsQuery = "SELECT COUNT(*) AS Cnt FROM sys.databases WHERE name = '$databaseName'"
$dbCount = (Invoke-Sqlcmd -ServerInstance $sqlServerInstance -Query $dbExistsQuery).Cnt

if ($dbCount -gt 0) {
    Write-Host "⚠️ Database '$databaseName' exists. Removing it..."
    $dropQuery = @"
ALTER DATABASE [$databaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [$databaseName];
"@
    Invoke-Sqlcmd -ServerInstance $sqlServerInstance -Query $dropQuery
    Write-Host "✅ Database '$databaseName' dropped successfully."
} else {
    Write-Host "✅ No existing database named '$databaseName'. Continuing..."
}

# ==============================
# RESTORE DATABASE
# ==============================
Write-Host "🧩 Restoring database from backup..."

Restore-SqlDatabase -ServerInstance $sqlServerInstance `
    -Database $databaseName `
    -BackupFile $downloadPath `
    -ReplaceDatabase `
    -RelocateFile @{"${databaseName}_Data"="$restoreDataPath${databaseName}_Data.mdf"; "${databaseName}_Log"="$restoreDataPath${databaseName}_Log.ldf"}

Write-Host "✅ Database '$databaseName' successfully restored from $($latestBlob.Name)"
