# PowerCLI Script for setting Disk Max IO Size
# @davidstamen
# http://davidstamen.com

#Define Variables
$cred = Get-Credential
$VC = "vc.lab.local"
$Cluster = "Production"

#Connect to vCenter
Connect-VIServer $VC -Credential $cred

#Get all Hosts
$esxHosts = Get-Cluster $Cluster | Get-VMHost | Where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | Sort Name

#For each host set DiskMaxIOsize to 4MB
foreach ($esx in $esxHosts) {
  Get-AdvancedSetting -Entity $esx -Name Disk.DiskMaxIOSize | Set-AdvancedSetting -Value 4096 -Confirm:$false
}
