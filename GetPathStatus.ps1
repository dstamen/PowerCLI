# PowerCLI Script for getting path selection policy for hosts
# @davidstamen
# http://davidstamen.com

$vmhosts = @(Get-VMHost)
foreach ($vmhost in $vmhosts) {
	$esxcli = Get-EsxCli -VMHost $vmhost
	$status = $esxcli.storage.nmp.device.list($null) | Select Device, DeviceDisplayName, PathSelectionPolicy
	Write-Host "==================================="
	Write-Host "$vmhost"
	$status
	Write-Host "==================================="

}
