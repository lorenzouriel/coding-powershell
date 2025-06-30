$Action = New-ScheduledTaskAction -Execute 'Example';

$startTime = [datetime]::Today

$Trigger = New-ScheduledTaskTrigger -Daily -At $startTime

$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest;

Register-ScheduledTask `
  -TaskName "ScheduleDaily" `
  -Action $Action `
  -Trigger $Trigger `
  -Principal $Principal `
  -Force