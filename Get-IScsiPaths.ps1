$VMHosts = Get-VMHost  | ? { $_.ConnectionState -eq "Connected" } | Sort-Object -Property Name
$results= @()

foreach ($VMHost in $VMHosts) {
[ARRAY]$HBAs = $VMHost | Get-VMHostHba -Type "IScsi"

    foreach ($HBA in $HBAs) {
    $pathState = $HBA | Get-ScsiLun | Get-ScsiLunPath | Group-Object -Property state
    $pathStateActive = $pathState | ? { $_.Name -eq "Active"}
    $pathStateDead = $pathState | ? { $_.Name -eq "Dead"}
    $pathStateStandby = $pathState | ? { $_.Name -eq "Standby"}
    $results += "{0},{1},{2},{3},{4},{5}" -f $VMHost.Name, $HBA.Device, $VMHost.Parent, [INT]$pathStateActive.Count, [INT]$pathStateDead.Count, [INT]$pathStateStandby.Count
    }

}
ConvertFrom-Csv -Header "VMHost","HBA","Cluster","Active","Dead","Standby" -InputObject $results | Ft -AutoSize
