$TemplateName = "template-windows2016"
$VMName = "ContentLibraryVM"
$Datastore = Get-DatastoreCluster "DatastoreCluster"
$Cluster = Get-Cluster "Cluster"
$custspec = Get-OSCustomizationSpec "windows_workgroup"
$ContentLibraryVM = Get-ContentLibraryItem -name $TemplateName |Where-Object {$_.ContentLibrary -like "*$Cluster*"}
New-VM -Datastore $Datastore -ResourcePool $Cluster -Name $VMName -ContentLibraryItem $ContentLibraryVM
if ($TemplateName -eq "template-windows2016") {
    Write-Host "Changing GuestId for Windows 2016" -ForegroundColor Green
    Set-VM -VM $VMName -GuestId windows9Server64Guest -Confirm:$false
}
Set-VM -VM $VMName -OSCustomizationSpec $custspec -Confirm:$false
Start-VM $VMName -Confirm:$false
