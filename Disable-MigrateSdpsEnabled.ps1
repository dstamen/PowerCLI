#Add Snapin
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue

#Define Variables
$cred = Get-Credential
$vCenter = "vc.lab.local"

Connect-VIServer $vCenter -Credential $cred

Foreach ($hostname in (Get-VMhost)) {
  Get-VMhost $hostname | Get-AdvancedSetting -name "Migrate.SdpsEnabled" | Set-AdvancedSetting -Value "0" -confirm:$false
}
Disconnect-VIServer * -Confirm:$false
