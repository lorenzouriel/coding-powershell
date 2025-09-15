# migration.ps1
param (
    [string]$Server = "localhost,14335",
    [string]$Database = "database",
    [string]$User = "sa",
    [string]$Password = "database@2025",
    [string]$Schema = "dbo",
    [string]$HistoryTable = "__migrations",
    [string]$ScriptsDir = ".\schemas\tables"
)

# Ensure sqlcmd exists
if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error "sqlcmd not found. Please install SQL Server Command Line Tools."
    exit 1
}

# Create migration history table if not exists
sqlcmd -S $Server -d $Database -U $User -P $Password -Q @"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$HistoryTable')
BEGIN
    CREATE TABLE [$Schema].[$HistoryTable] (
        id INT IDENTITY(1,1) PRIMARY KEY,
        filename NVARCHAR(255) NOT NULL,
        applied_at DATETIME DEFAULT GETDATE()
    );
END;
"@

# Get already applied migrations
$applied = sqlcmd -S $Server -d $Database -U $User -P $Password -h -1 -W -Q "SET NOCOUNT ON; SELECT filename FROM [$Schema].[$HistoryTable];"

# Loop through files
Get-ChildItem $ScriptsDir -Filter *.sql | Sort-Object Name | ForEach-Object {
    $file = $_.FullName
    $filename = $_.Name

    if ($applied -match $filename) {
        Write-Host "Skipping $filename (already applied)"
    } else {
        Write-Host "Applying $filename..."
        sqlcmd -S $Server -d $Database -U $User -P $Password -i $file
        if ($LASTEXITCODE -eq 0) {
            sqlcmd -S $Server -d $Database -U $User -P $Password -Q "INSERT INTO [$Schema].[$HistoryTable] (filename) VALUES ('$filename');"
            Write-Host "Applied $filename"
        } else {
            Write-Error "Failed applying $filename. Stopping."
            exit 1
        }
    }
}

Write-Host "🎉 Deployment finished!"