# Description: Continuously counts incoming connection attempts to port 80

$totalAttempts = 0
$intervalSeconds = 5  # check every 5 seconds

Write-Host "Counting connection attempts to port 80..."
Write-Host "Press Ctrl+C to stop."

while ($true) {
    # Get all SYN_RECEIVED connections (attempted connections)
    $synConnections = Get-NetTCPConnection -LocalPort 80 | Where-Object { $_.State -eq "SynReceived" }

    # Count them
    $count = $synConnections.Count
    $totalAttempts += $count

    # Output current interval count and total
    Write-Host "$(Get-Date -Format 'HH:mm:ss') | Interval Attempts: $count | Total Attempts: $totalAttempts"

    Start-Sleep -Seconds $intervalSeconds
}
 
##########################
# Count Per IPs
###########################
# Description: Prints number of connection attempts to port 80 per remote IP in real-time

$intervalSeconds = 5  # Check every 5 seconds
$totalAttempts = @{}  # Hashtable to keep cumulative count per IP

Write-Host "Monitoring incoming SYN requests to port 80..."
Write-Host "Press Ctrl+C to stop."

while ($true) {
    # Get all SYN_RECEIVED connections (attempted connections)
    $connections = Get-NetTCPConnection -LocalPort 80 | Where-Object { $_.State -eq "SynReceived" }

    # Reset interval counts
    $intervalCounts = @{}

    foreach ($conn in $connections) {
        $ip = $conn.RemoteAddress
        # Count interval attempts
        if ($intervalCounts.ContainsKey($ip)) {
            $intervalCounts[$ip] += 1
        } else {
            $intervalCounts[$ip] = 1
        }

        # Count total attempts
        if ($totalAttempts.ContainsKey($ip)) {
            $totalAttempts[$ip] += 1
        } else {
            $totalAttempts[$ip] = 1
        }
    }

    # Print interval summary
    Write-Host "`n$(Get-Date -Format 'HH:mm:ss') | Interval Connection Attempts:"
    foreach ($ip in $intervalCounts.Keys) {
        Write-Host "  $ip : $($intervalCounts[$ip]) | Total: $($totalAttempts[$ip])"
    }
        # Print sorted by total attempts descending
    $sortedIPs = $totalAttempts.GetEnumerator() | Sort-Object -Property Value -Descending
    Write-Host "`n$(Get-Date -Format 'HH:mm:ss') | Top connection attempts:"
    foreach ($entry in $sortedIPs) {
        Write-Host "  $($entry.Key) : Total Attempts: $($entry.Value)"
    }


    Start-Sleep -Seconds $intervalSeconds
}
