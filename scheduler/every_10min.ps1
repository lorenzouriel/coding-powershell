$Action = New-ScheduledTaskAction -Execute 'C:\Program Files\Microsoft SQL Server\150\DTS\Binn\DTExec.exe' `
  -Argument '/F "C:\SSIS\job.dtsx" /Decrypt "Password"';

$startTime = [datetime]::Today

$Trigger = New-ScheduledTaskTrigger -Once -At $startTime `
  -RepetitionInterval (New-TimeSpan -Minutes 10) `
  -RepetitionDuration (New-TimeSpan -Days 360)

$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest;

Register-ScheduledTask `
  -TaskName "Every10Min" `
  -Action $Action `
  -Trigger $Trigger `
  -Principal $Principal `
  -Force