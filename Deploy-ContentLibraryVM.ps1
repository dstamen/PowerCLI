$TemplateName = "2012R2"
$VMName = "TEST01"
$Datastore = "Datastore"
$Cluster = "Cluster"
$custspec = "windows"
Get-ContentLibraryItem -Name $TemplateName|New-VM -Datastore $Datastore -ResourcePool $Cluster -Name $VMName
Set-VM -VM $VMName -OSCustomizationSpec $custspec -Confirm:$false
Start-VM $VMName -Confirm:$false