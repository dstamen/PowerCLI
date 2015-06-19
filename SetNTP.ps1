# PowerCLI Script for adding ntp to hosts
# @davidstamen
# http://davidstamen.com

# Setup common variables to use
$vcenter = "vc.lab.local"

# Connect to vCenter
Connect-VIServer -Server $vcenter

#Set NTP server for all hosts
Get-VMHost | Add-VMHostNTPServer -NTPserver us.pool.ntp.org

#Restart NTP services on host
Get-VMHost | Get-VMHostService | Where-Object {$_.key -eq "ntpd"} | Stop-VMHostService
Get-VMHost | Get-VMHostService | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService

#Set service to start automatically
Get-VMHost | Get-VMHostService | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "on"
