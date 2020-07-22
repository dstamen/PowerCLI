$vmhs = Get-Cluster | Get-VMHost | sort Name
foreach ($vmh in $vmhs){
Write-Host $vmh.Name " - " $vmh.build -ForegroundColor Green
$esxcli = Get-EsxCli -VMHost $vmh
$face = $esxcli.software.vib.list()
$esxcli.system.module.get("enic").version
$esxcli.system.module.get("fnic").version
Write-Host ""
}
