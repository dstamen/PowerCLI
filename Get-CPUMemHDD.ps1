# PowerCLI Script for getting total amount of resouces within a vCenter
# @davidstamen
# http://davidstamen.com

#Define Variables
$cred = Get-Credential
$VC = "vc.lab.local"
$Location = "Production"

#Connect to vCenter
Connect-VIServer $VC -Credential $cred

#Populate VM's based on Location (Cluster, ResourcePool, Host)
$VMs = Get-VM -Location $Location

$TotalVMs = $VMs | Measure-Object
$TotalCPU = $VMs | Measure-Object -Sum -Property NumCPU | Select Sum
$TotalMem = $VMs | Measure-Object -Sum -Property MemoryGB | Select Sum
$TotalHDD = $VMs | Measure-Object -Sum -Property ProvisionedSpaceGB

#Write results to screen
Write-Host "In" $VC $Location "has" $TotalVMs.Count "VM's," $TotalCPU.Sum "CPU's," $TotalMem.Sum "GB of RAM," and $TotalHDD.Sum "GB of HDD allocated"
