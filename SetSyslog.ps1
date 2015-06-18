# PowerCLI Script for adding syslogserver to hosts
# @davidstamen
# http://davidstamen.com

# Setup common variables to use
$vcenter = "vcenter.lab.local"
$syslogservers = "udp://syslog.lab.local:514"

Connect-VIServer -Server $vcenter

# Setup variable to use in script for all hosts in vCenter
$vmhosts = @(Get-VMHost)

# Configure syslog on each host in vCenter
foreach ($vmhost in $vmhosts) {
	Set-VMHostAdvancedConfiguration -Name Syslog.global.logHost -Value "$syslogservers" -VMHost $vmhost
	$esxcli = Get-EsxCli -VMHost $vmhost
	$esxcli.system.syslog.reload()
}

# Disconnect from vCenter
Disconnect-VIServer * -Confirm:$false
