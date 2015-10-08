# Variables
$vcenter = "vc.lab.local"
$esxusername = "root"
$esxpassword = "password"
$DSC = "DSC01"
$Datacenter = "Lab"

#Connect to vCenter
#Connect-VIServer -Server $vCenter

# Create Datacenters
Write-Host "Creating Datacenter" -ForegroundColor "Green"
$csv = Import-CSV .\createdatacenter.csv
foreach ($datacenter in $csv) {
  New-Datacenter -Location (Get-Folder -NoRecursion) -Name $datacenter.Name
}

# Create Clusters
Write-Host "Creating Clusters" -ForegroundColor "Green"
$csv = Import-CSV .\createcluster.csv
foreach ($cluster in $csv) {
  New-Cluster -Name $cluster.Name -Location $cluster.Datacenter -DRSEnabled -DrsAutomationLevel FullyAutomated -HAEnabled
}

# Create Clusters
Write-Host "Adding Hosts" -ForegroundColor "Green"
$csv = Import-CSV .\createhosts.csv
foreach ($vmhost in $csv) {
  Add-VMHost -Name $vmhost.Name -Location $vmhost.Cluster -User $esxusername -Password $esxpassword
  Set-VMHost -VMHost $vmhost.Name -State Maintenance
}

# Create Datastores
Write-Host "Creating Datastores" -ForegroundColor "Green"
$csv = Import-CSV .\createdatastores.csv
foreach ($datastore in $csv) {
  New-Datastore -VMHost $datastore.host -Name $datastore.Name -Path $datastore.NAAID -VMFS
}

# Create Datastore Cluster and Move Datastores In
Write-Host "Creating Datastore Cluster and Adding Datastores" -ForegroundColor "Green"
$csv = Import-CSV .\createdatastores.csv
New-DatastoreCluster -Name $DSC -Location $Datacenter
foreach ($datastore in $csv) {
  Move-Datastore $datastore.Name -Destination $datastore.DatastoreCluster
}

# Apply HostProfile
Write-Host "Applying HostProfiles" -ForegroundColor "Green"
$csv = Import-CSV .\applyhostprofile.csv
foreach ($hostprofile in $csv) {
  Apply-VMHostProfile -Entity $hostprofile.Entity -Profile $hostprofile.Profile -Confirm:$false
}

Write-Host "Complete!" -ForegroundColor "Green"
