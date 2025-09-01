# Description: Logs all remote IPs connecting to port 80 in real-time

$LogFile = "C:\temp\Port80_Connections.log"

# Create log file if it doesn't exist
if (!(Test-Path $LogFile)) {
    New-Item -Path $LogFile -ItemType File -Force
}

Write-Host "Monitoring incoming connections to port 80..."
Write-Host "Logging to $LogFile"

while ($true) {
    # Get all TCP connections on local port 80
    $connections = Get-NetTCPConnection -LocalPort 80 | Where-Object { $_.State -eq "SynReceived" -or $_.State -eq "Established" }

    foreach ($conn in $connections) {
        $entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | State: $($conn.State) | Remote IP: $($conn.RemoteAddress)"
        # Append entry to log file if not already logged recently
        Add-Content -Path $LogFile -Value $entry
    }

    Start-Sleep -Seconds 5  # Adjust polling interval if needed
}
 