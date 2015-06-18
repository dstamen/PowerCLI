$vmhosts = @(Get-VMHost)
foreach ($vmhost in $vmhosts) {
	$esxcli = Get-EsxCli -VMHost $vmhost
	$status = $esxcli.storage.nmp.device.list($null) | Select Device, DeviceDisplayName, PathSelectionPolicy
	Write-Host "==================================="
	Write-Host "$vmhost"
	$status
	Write-Host "==================================="

}