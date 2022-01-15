Write-Host "Welcome to script to get utilization report for multiple VM in CSV format"
Write-Host "                        "

$Server = Read-Host -Prompt 'Input Vcenter IP or FQDN'
Write-Host "Please wait while we try to connect.... "
Connect-VIServer -server $Server

$c="true"
[DateTime]$start = Read-Host -Prompt 'Enter start date (Format: MM/DD/YYYY) '
[DateTime]$Finish = Read-Host -Prompt 'Enter end date (Format: MM/DD/YYYY) '

if($c)
{
  if($start -gt $Finish)
   {
    Write-Host "                        "
    Write-Host "Error : Start date is greater than end date, please re-enter the dates"
    Write-Host "                        "
    [DateTime]$start = Read-Host -Prompt 'Enter start date (Format: MM/DD/YYYY) '
    [DateTime]$Finish = Read-Host -Prompt 'Enter end date (Format: MM/DD/YYYY) '
   }
   else
   {
   $c="false"
   }

}


Write-Host "                        "
Write-Host " Please create a text file with all the servers you need report"
Write-Host " Example : C:\Users\SugatoChoudhury\Desktop\Server_list\servers.txt"
Write-Host "                        "



$Location = Read-Host -Prompt 'Please enter the loacation with file name, refer the above example'
Write-Host "                        "
Write-Host " Please wait while report is being cooked"

$Location2=  split-path -Path $Location


$file_data = Get-Content $Location


$allvms = @()
$vms = Get-Vm -Name $file_data  
$metrics = "cpu.usage.average","mem.usage.average"
$stats = Get-Stat -Entity $vms -Start $start -Finish $Finish -Stat $metrics   
$stats | Group-Object -Property {$_.Timestamp.Day},{$_.Entity.Name} | %{
  $vmstat = "" | Select VmName, Day, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin
  $vmstat.VmName = $_.Values[1]
  $vmstat.Day = $_.Group[0].Timestamp.Date
  $cpu = $_.Group | where {$_.MetricId -eq "cpu.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum
  $mem = $_.Group | where {$_.MetricId -eq "mem.usage.average"} | Measure-Object -Property value -Average -Maximum -Minimum
  $vmstat.CPUMax = [int]$cpu.Maximum
  $vmstat.CPUAvg = [int]$cpu.Average
  $vmstat.CPUMin = [int]$cpu.Minimum
  $vmstat.MemMax = [int]$mem.Maximum
  $vmstat.MemAvg = [int]$mem.Average
  $vmstat.MemMin = [int]$mem.Minimum  
  $allvms += $vmstat
}
$allvms | Export-Csv "$Location2\Utilization_Report.csv" -noTypeInformation

Write-Host "                        "

Write-Host "Report named Utilization_Report has been generated in $location2 "
Write-Host "            *********Thank You******** "

