$vmhosts = @(Get-VMHost)

# Configure syslog on each host in vCenter
foreach ($vmhost in $vmhosts) {
	$esxcli = Get-EsxCli -VMHost $vmhost
	$esxcli.system.syslog.reload()
}
