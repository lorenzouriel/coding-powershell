while ($true) {
    cls
    Write-Host "Active connections on ports 80 and 443 - $(Get-Date)" -ForegroundColor Cyan
    netstat -an | findstr ":80" | findstr ESTABLISHED | ForEach-Object { ($_ -split "\s+")[-2] } |
        ForEach-Object { ($_ -split ":")[0] } |
        Group-Object | Sort-Object Count -Descending |
        Select-Object Count, Name

    netstat -an | findstr ":443" | findstr ESTABLISHED | ForEach-Object { ($_ -split "\s+")[-2] } |
        ForEach-Object { ($_ -split ":")[0] } |
        Group-Object | Sort-Object Count -Descending |
        Select-Object Count, Name

    Start-Sleep 5
}