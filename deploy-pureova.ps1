# PowerCLI Script to deploy Pure Storage VMware Appliance
# @davidstamen
# https://davidstamen.com

$vcname = "vc01.my.lab"
$vcuser = "administrator@vsphere.local"
$vcpass = "VMware1!"


$ovffile = "C:\share\pure-vmware-appliance_3.2.0-prod-signed.ova" #Online OVA https://static.pure1.purestorage.com/vm-analytics-collector/pure-vmware-appliance_3.2.0-prod-signed.ova
$cluster = "MyCluster"
$vmnetwork = "MyNetwork"
$datastore = "MyDatastore"
$vmfolder = "MyFolder"
$vmname = "pureplugin.my.lab"
$vmip = "10.21.234.27"
$netmask = "255.255.255.0"
$gateway = "10.21.234.1"
$dns1 = "10.21.234.10"
$dns2 = "10.21.234.11"
$appliancetype = "vSphere Remote Client Plugin" #"VM Analytics Collector","vSphere Remote Client Plugin", "None (Offline Installation)"
$dhcp = $false #true if dhcp, false if static

$vcenter = Connect-VIServer $vcname -User $vcuser -Password $vcpass -WarningAction SilentlyContinue

$datastore_ref = Get-Datastore -Name $datastore
$network_ref = Get-VirtualPortGroup -Name $vmnetwork
$cluster_ref = Get-Cluster -Name $cluster
$vmhost_ref = $cluster_ref | Get-VMHost | Select-Object -First 1

$ovfconfig = Get-OvfConfiguration $ovffile

$ovfconfig.NetworkMapping.VM_Network.Value = $network_ref
$ovfconfig.Common.Appliance_Type.Value = $appliancetype
$ovfconfig.Common.DHCP.Value = $dhcp
if ($dhcp -eq $false) {
    $ovfconfig.Common.IP_Address.Value = $vmip
    $ovfconfig.Common.NetMask.Value = $netmask
    $ovfconfig.Common.Gateway.Value = $gateway
    $ovfconfig.Common.DNS_Server_1.Value = $dns1
    $ovfconfig.Common.DNS_Server_2.Value = $dns2
    $ovfconfig.Common.Hostname.Value = $vmname
}

#Deploy OVA
Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name $vmname -InventoryLocation $vmfolder -Location $cluster_ref -VMHost $vmhost_ref -Datastore $datastore_ref -Server $vcenter

$vm = get-vm $vmname
$vm | Start-Vm -RunAsync | Out-Null

Disconnect-VIServer $vcenter -Confirm:$false