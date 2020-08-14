$vcname = "vc.lab.local"
$vcuser = "administrator@vsphere.local"
$vcpass = "VMware1!"
$vccluster = "cluster01"
$volname = "ds01"
$volcapacityTB = "5"

$pureendpoint = "flasharray.lab.local"
$pureuser = "pureuser"
$purepass = ConvertTo-SecureString "pureuser" -AsPlainText -Force
$purecred = New-Object System.Management.Automation.PSCredential -ArgumentList ($pureuser, $purepass)

#Connect to Flash Array
$array = New-PfaConnection -endpoint $pureendpoint -credentials $purecred -defaultarray

#Connect to vCenter Server
$vc = Connect-VIServer $vcname -User $vcuser -Password $vcpass -WarningAction SilentlyContinue

#Create Hosts and Hostgroup
New-PfaHostGroupfromVcCluster -flasharray $array -cluster (Get-Cluster $vccluster -server $vc) -iscsi

#Configure ESXi Cluster for ISCSI to Flash Array
Set-ClusterPfaiSCSI -cluster (Get-Cluster $vccluster) -flasharray $array

#Create Volume, Attach to HostGroup and Provision VMFS Datastore
New-PfaVmfs -flasharray $array -cluster (Get-Cluster $vccluster -server $vc) -volName $volname -sizeInTB $volcapacityTB

#Disconnect from vCenter Server
Disconnect-VIServer -server $vc -Confirm:$false

#Disconnect Array
$array = $null
