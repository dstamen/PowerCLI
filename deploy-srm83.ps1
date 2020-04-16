# PowerCLI Script to deploy SRM 8.3 OVF
# @davidstamen
# https://davidstamen.com

$vcname = "vc01.my.lab"
$vcuser = "administrator@vsphere.local"
$vcpass = "VMware1!"

$ovffile = "C:\share\VMware\SRM\VMware-srm-va-8.3.0.4135-15929234\bin\srm-va_OVF10.ovf"
$cluster = "MyCluster"
$vmnetwork = "MyNetwork"
$datastore = "MyDatastore"
$vmfolder = "MyFolder"
$vm1name = "srm1.my.lab"
$vm2name = "srm2.my.lab"
$vm1ip = "10.21.230.58"
$vm2ip = "10.21.230.59"
$addrfamily = "ipv4"
$networkmode = "static"
$gateway = "10.21.230.1"
$domain = "my.lab"
$searchpath = "my.lab"
$dns = "10.21.230.6"
$prefix = "24"
$ntp = "us.pool.ntp.org"
$password = "VMware1!"
$enablessh = $true

$vcenter = Connect-VIServer $vcname -User $vcuser -Password $vcpass -WarningAction SilentlyContinue

$datastore_ref = Get-Datastore -Name $datastore
$network_ref = Get-VirtualPortGroup -Name $vmnetwork
$cluster_ref = Get-Cluster -Name $cluster
$vmhost_ref = $cluster_ref | Get-VMHost | Select -First 1

$ovfconfig.NetworkMapping.Network_1.value = $vmnetwork
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.addrfamily.value  = $addrfamily
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.netmode.value  = $networkmode
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.gateway.value  = $gateway
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.domain.value  = $domain
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.searchpath.value = $searchpath
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.DNS.value = $dns
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.netprefix0.value = $prefix
$ovfconfig.common.ntpserver.value = $ntp
$ovfconfig.common.varoot_password.value = $password
$ovfconfig.common.vaadmin_password.value = $password
$ovfconfig.common.dbpassword.value = $password
$ovfconfig.common.enable_sshd.value = $enablessh

#Deploy SRM1
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.ip0.value = $vm1ip
$ovfconfig.common.vami.hostname.value = $vm1ip
Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name $vm1name -InventoryLocation $VMFolder -Location $cluster_ref -VMHost $vmhost_ref -Datastore $datastore_ref

#Deploy SRM2
$ovfconfig.network.VMware_Site_Recovery_Manager_Appliance.ip0.value = $vm2ip
Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name $vm2name -InventoryLocation $VMFolder -Location $cluster_ref -VMHost $vmhost_ref -Datastore $datastore_ref

$vms = get-vm $vm1name,$vm2name
$vm | Start-Vm -RunAsync | Out-Null

Disconnect-VIServer $vcenter -Confirm:$false