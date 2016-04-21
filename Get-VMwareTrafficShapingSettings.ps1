# PowerCLI Script for Getting Traffic Shapping Settings for All VirtualPortGroup on VirtualSwitch
# @davidstamen
# http://davidstamen.com
# Powershel Functions provided by @LucD http://www.lucd.info/2011/06/11/dvswitch-scripting-part-9-traffic-shaping/

function Get-dvPgTrafficShaping{
<#
.SYNOPSIS
Returns the traffic shaping settings for a dvSwitch portgroup
.DESCRIPTION
The function will return all traffic shaping settings for a dvSwitch portgroup
.NOTES
Author:  Luc Dekens
.PARAMETER dvPg
An object that represents a dvPortgroup as returned by the
Get-dVsWPg function
.EXAMPLE
PS> Get-dvSwPg $dvSw $dvPgName | Get-dvPgTrafficShaping
#>

   [CmdletBinding()]
   param(
   [parameter(Mandatory = $true, ValueFromPipeline = $true)]
   [PSObject]$dvPg)

   $ts = New-Object PSObject

   $ingress = $dvPg.Config.DefaultPortConfig.InshapingPolicy
   Add-Member -InputObject $ts -Name IngressState -Value $ingress.Enabled.Value -MemberType NoteProperty
   if($ingress.Enabled.Value){
      Add-Member -InputObject $ts -Name "InAverage (Kbps)" -Value ($ingress.AverageBandwidth.Value/1000) -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "InBurst (KB)" -Value ($ingress.BurstSize.Value/1KB) -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "InPeak (Kbps)" -Value ($ingress.PeakBandwidth.Value/1000) -MemberType NoteProperty
   }
   else{
      Add-Member -InputObject $ts -Name "InAverage (Kbps)" -Value "na" -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "InBurst (KB)" -Value "na" -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "InPeak (Kbps)" -Value "na" -MemberType NoteProperty
   }

   $egress = $dvPg.Config.DefaultPortConfig.OutshapingPolicy
   Add-Member -InputObject $ts -Name EgressState -Value $egress.Enabled.Value -MemberType NoteProperty
   if($egress.Enabled.Value){
      Add-Member -InputObject $ts -Name "OutAverage (Kbps)" -Value ($egress.AverageBandwidth.Value/1000) -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "OutBurst (KB)" -Value ($egress.BurstSize.Value/1KB) -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "OutPeak (Kbps)" -Value ($egress.PeakBandwidth.Value/1000) -MemberType NoteProperty
   }
   else{
      Add-Member -InputObject $ts -Name "OutAverage (Kbps)" -Value "na" -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "OutBurst (KB)" -Value "na" -MemberType NoteProperty
      Add-Member -InputObject $ts -Name "OutPeak (Kbps)" -Value "na" -MemberType NoteProperty
   }

   $ts
}
function Get-dvSwPg{
  param($dvSw,
    [string]$PGName,
    [int]$VLANnr)

# Search for Portgroup Name
  if($PGName){
    $dvSw.Portgroup | %{Get-View -Id $_} | `
      where{$_.Name -eq $PGName}
  }
# Search for VLAN number
  elseif($VLANnr){
    $dvSw.Portgroup | %{Get-View -Id $_} | `
      where{$_.Config.DefaultPortConfig.Vlan.VlanId -eq $VLANnr}
  }
}
Foreach ($VirtualSwitch in Get-VirtualSwitch -Distributed)  {
  Foreach ($VirtualPortGroup in Get-VirtualPortGroup -VirtualSwitch $VirtualSwitch) {
      Write "$VirtualPortGroup on $VirtualSwitch"
      $dvPg = Get-dvSwPg -dvSw $VirtualSwitch.ExtensionData -PGName $VirtualPortGroup
      Get-dvPgTrafficShaping -dvPg $dvPg|fl
  }
}
