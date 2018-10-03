Connect-VIServer "ds-vcsa-03.cpbu.lab" | Out-Null
$VDSwitch = "VDS"
$VDVersion = "6.6.0"
$Cluster = Get-Cluster "Cluster"

If ($Cluster.DrsEnabled -like "True") {
    Write-Host "DRS is Enabled, it will be temporarily disabled during upgrade." -ForegroundColor "Green"
    $ClusterDRSLevel = $Cluster.DrsAutomationLevel
    Write-Host "DRS Cluster is currently set to $ClusterDRSLevel. Will change back when complete." -ForegroundColor "Green"
    Get-Cluster $Cluster | Set-Cluster -DrsAutomationLevel "PartiallyAutomated" -Confirm:$false
    Get-VDSwitch -Name $VDSwitch | Export-VDSwitch -Description "My Backup" -Destination "/PathToBackup/VDSBackup-$VDswitch-$((Get-Date).ToString(‘yyyy-MM-dd-hh-mm’)).zip"
    Get-VDSwitch -Name $VDSwitch | Set-VDSwitch -Version $VDVersion
    Write-Host "Upgrade is complete. Setting Cluster to $ClusterDRSLevel." -ForegroundColor "Green"
    Get-Cluster $Cluster | Set-Cluster -DrsAutomationLevel $ClusterDRSLevel -Confirm:$false
}
ElseIf ($Cluster.DrsEnabled -like "False") {
    Write-Host "DRS is Disabled, No additional action needed." -ForegroundColor "Green"
    Get-VDSwitch -Name $VDSwitch | Export-VDSwitch -Description "My Backup" -Destination "/PathToBackup/VDSBackup-$VDswitch-$((Get-Date).ToString(‘yyyy-MM-dd-hh-mm’)).zip"
    Get-VDSwitch -Name $VDSwitch | Set-VDSwitch -Version $VDVersion
}
