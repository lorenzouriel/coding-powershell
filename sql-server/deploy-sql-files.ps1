param (
    [string]$Server = "host,1433",
    [string]$Database = "database",
    [string]$User = "user",
    [string]$Password = "pass@2025",
    [string]$ScriptsDir = ".\database\migrations"
)

# Ensure sqlcmd exists
if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Error "sqlcmd not found."
    exit 1
}

# Get already applied migrations
$applied = sqlcmd -S $Server -d $Database -U $User -P $Password -h -1 -W -Q "SELECT filename FROM migrations;"

# Run each SQL file
Get-ChildItem $ScriptsDir -Filter *.sql | Sort-Object Name | ForEach-Object {
    $file = $_.FullName
    $filename = $_.Name

    if ($applied -match $filename) {
        Write-Host "Skipping $filename"
    } else {
        Write-Host "Applying $filename..."
        sqlcmd -S $Server -d $Database -U $User -P $Password -i $file

        if ($LASTEXITCODE -eq 0) {
            sqlcmd -S $Server -d $Database -U $User -P $Password -Q "INSERT INTO migrations (filename) VALUES ('$filename');"
            Write-Host "Applied $filename"
        } else {
            Write-Error "Failed $filename"
            exit 1
        }
    }
}

Write-Host "Deployment finished!"