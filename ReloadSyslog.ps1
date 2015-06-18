# PowerCLI Script for reloading syslogserver on hosts
# @davidstamen
# http://davidstamen.com

# Setup common variables to use
$vcenter = "vcenter.lab.local"

# Connect to vCenter
Connect-VIServer -Server $vcenter

# Get hosts
$vmhosts = @(Get-VMHost)

# Configure syslog on each host in vCenter
foreach ($vmhost in $vmhosts) {
	$esxcli = Get-EsxCli -VMHost $vmhost
	$esxcli.system.syslog.reload()
}
