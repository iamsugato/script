Write-Host "Welcome to script to get status of latest VAMI backup"

Write-Host "                        "


$Server = Read-Host -Prompt 'Input Vcenter IP or FQDN'
$User = Read-Host -Prompt 'Input the username has access to VCSA'
$Pass = Read-Host -Prompt 'Input password'
$Date = Get-Date

Write-Host "                        "

Write-Host "Please wait while we try to connect.... "

connect-cisserver -Server $Server -User $USer -Password $Pass

$backupjob = Get-CisService -Name com.vmware.appliance.recovery.backup.job 

$result = $backupjob.list() 

Write-Host "                        "

Write-Host "Status of latest VAMI backup for '$Server'"

Write-Host "                        "

$backupjob.get($result[0]) | select-object id, start_time, end_time, progress, state  



Write-Host "  ****Thank You******  "
