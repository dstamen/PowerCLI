# PowerCLI Script for cloning VMs and customizing disk, cpu and memory
# @davidstamen
# http://davidstamen.com

$vmlist = Import-CSV '.\VMs.csv'

foreach ($item in $vmlist) {
    $basevm = $item.basevm
    $datastore = $item.datastore
    $vmcluster = $item.vmcluster
    $custspec = $item.custspec
    $vmname = $item.vmname
    $ipaddr = $item.ipaddress
    $subnet = $item.subnet
    $gateway = $item.gateway
    $pdns = $item.pdns
    $sdns = $item.sdns
    $vlan = $item.vlan
    $sdisk = $item.sdisk
    $folder = $item.folder
    $totalcpu = $item.totalcpu
    $corespersocket = $item.corespersocket
    $memorygb = $item.memorygb

    #Get the Specification and set the Nic Mapping
    Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns

    #Clone the BaseVM with the adjusted Customization Specification
    New-VM -Name $vmname -Location $folder -VM $basevm -Datastore $datastore -ResourcePool $vmcluster -OSCustomizationSpec $custspec
    Get-NetworkAdapter -VM $vmname|Set-NetworkAdapter -NetworkName $vlan -confirm:$false
    #Add second disk if one is listed
    if ($sdisk -gt "1") {
      New-HardDisk -vm $vmname -CapacityGB $sdisk -Datastore $datastore -StorageFormat "EagerZeroedThick"
    }
    #adjust number of cpu's and sockets
    $spec = new-object -typename VMware.VIM.virtualmachineconfigspec -property @{'numcorespersocket'=$corespersocket;'numCPUs'=$totalcpu}
    (Get-VM $vmname).ExtensionData.ReconfigVM_Task($spec)

    #adjust memory allocation
    Set-VM -VM $vmname -MemoryGB $memorygb -confirm:$false
   }
