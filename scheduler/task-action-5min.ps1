$Action = New-ScheduledTaskAction -Execute 'Example';

$startTime = [datetime]::Today

$Trigger = New-ScheduledTaskTrigger -Once -At $startTime `
  -RepetitionInterval (New-TimeSpan -Minutes 5) `
  -RepetitionDuration (New-TimeSpan -Days 360)

$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest;

Register-ScheduledTask `
  -TaskName "Every05Min" `
  -Action $Action `
  -Trigger $Trigger `
  -Principal $Principal `
  -Force