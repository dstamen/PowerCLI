# PowerCLI Script for getting path selection policy for hosts
# @davidstamen
# http://davidstamen.com

# Setup common variables to use
$vcenter = "vcenter.lab.local"

# Connect to vCenter
Connect-VIServer -Server $vcenter

$vmhosts = @(Get-VMHost)
foreach ($vmhost in $vmhosts) {
	$esxcli = Get-EsxCli -VMHost $vmhost
	$status = $esxcli.storage.nmp.device.list($null) | Select Device, DeviceDisplayName, PathSelectionPolicy
	Write-Host "==================================="
	Write-Host "$vmhost"
	$status
	Write-Host "==================================="

}
