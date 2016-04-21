# PowerCLI Script for Setting Traffic Shapping Settings for All VirtualPortGroup on VirtualSwitch
# @davidstamen
# http://davidstamen.com
# Powershel Functions provided by @LucD http://www.lucd.info/2011/06/11/dvswitch-scripting-part-9-traffic-shaping/

function Set-dvPgTrafficShaping{
<#
.SYNOPSIS
Configure traffic shaping on a dvSwitch portgroup
.DESCRIPTION
The function will configure ingress (VM to switch)
and egress (switch to VM) traffic shaping for a specific
dvSwitch portgroup
.NOTES
Author:  Luc Dekens
.PARAMETER dvPg
An object that represents a dvPortgroup as returned by the
Get-dVsWPg function
.PARAMETER InShaping
 A switch which indicates if inshaping (ingress) should be
enabled or not
.PARAMETER inAverageKbps
The value, in Kbits/sec, for the ingress average bandwidth.
If the value is -1, the setting will be left unchanged.
.PARAMETER inBurstKB
The value, in Kbytes, for the ingress burst size
If the value is -1, the setting will be left unchanged.
.PARAMETER inPeakKbps
The value, in Kbits/sec, for the ingress peak bandwidth
If the value is -1, the setting will be left unchanged.
.PARAMETER OutShaping
A switch which indicates if outshaping (egress) should be
enabled or not
.PARAMETER outAverageKbps
The value, in Kbits/sec, for the average bandwidth
If the value is -1, the setting will be left unchanged.
.PARAMETER outBurstKB
The value, in Kbytes, for the burst size
If the value is -1, the setting will be left unchanged.
.PARAMETER outPeakKbps
The value, in Kbits/sec, for the peak bandwidth
If the value is -1, the setting will be left unchanged.
.EXAMPLE
PS> Get-dvSwPg $dvSw $dvPgName | `
 >> Set-dvPgTrafficShaping -IShaping:$false `
 >>    -OutShaping -outAverage 100000 `
 >>    -outPeak 100000 `
 >>    -outBurst 102400
#>

   [CmdletBinding()]
   param(
   [parameter(Mandatory = $true, ValueFromPipeline = $true)]
   [PSObject]$dvPg,
   [switch]$InShaping,
   [long]$inAverageKbps,
   [long]$inBurstKB,
   [long]$inPeakKbps,
   [switch]$OutShaping,
   [long]$outAverageKbps,
   [long]$outBurstKB,
   [long]$outPeakKbps
   )

   $spec = New-Object VMware.Vim.DVPortgroupConfigSpec
   $spec.ConfigVersion = $dvPg.Config.ConfigVersion
   $spec.DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting
   if($InShaping){
      $spec.DefaultPortConfig.InShapingPolicy = New-Object VMware.Vim.DVSTrafficShapingPolicy
      $spec.DefaultPortConfig.InShapingPolicy.Enabled = New-Object VMware.Vim.BoolPolicy
      $spec.DefaultPortConfig.InShapingPolicy.Enabled.Value = $true
      $spec.DefaultPortConfig.InShapingPolicy.Enabled.Inherited = $false
      if($inAverageKbps -ne -1){
         $spec.DefaultPortConfig.InShapingPolicy.averageBandwidth = New-Object VMware.Vim.LongPolicy
         $spec.DefaultPortConfig.InShapingPolicy.averageBandwidth.Value = $inAverageKbps * 1000
         $spec.DefaultPortConfig.InShapingPolicy.averageBandwidth.Inherited = $false
      }
      if($inBurstKB -ne -1){
         $spec.DefaultPortConfig.InShapingPolicy.burstSize = New-Object VMware.Vim.LongPolicy
         $spec.DefaultPortConfig.InShapingPolicy.burstSize.Value = $inBurstKB * 1KB
         $spec.DefaultPortConfig.InShapingPolicy.burstSize.Inherited = $false
      }
      if($inPeakKbps -ne -1){
         $spec.DefaultPortConfig.InShapingPolicy.peakBandwidth = New-Object VMware.Vim.LongPolicy
         $spec.DefaultPortConfig.InShapingPolicy.peakBandwidth.Value = $inPeakKbps * 1000
         $spec.DefaultPortConfig.InShapingPolicy.peakBandwidth.Inherited = $false
      }
   }
   else{
      $spec.DefaultPortConfig.InShapingPolicy = New-Object VMware.Vim.DVSTrafficShapingPolicy
      $spec.DefaultPortConfig.InShapingPolicy.Enabled = New-Object VMware.Vim.BoolPolicy
      $spec.DefaultPortConfig.InShapingPolicy.Enabled.Value = $false
      $spec.DefaultPortConfig.InShapingPolicy.Enabled.Inherited = $true
   }

   if($OutShaping){
      $spec.DefaultPortConfig.OutShapingPolicy = New-Object VMware.Vim.DVSTrafficShapingPolicy
      $spec.DefaultPortConfig.OutShapingPolicy.Enabled = New-Object VMware.Vim.BoolPolicy
      $spec.DefaultPortConfig.OutShapingPolicy.Enabled.Value = $true
      $spec.DefaultPortConfig.OutShapingPolicy.Enabled.Inherited = $false
      if($outAverageKbps -ne -1){
         $spec.DefaultPortConfig.OutShapingPolicy.averageBandwidth = New-Object VMware.Vim.LongPolicy
         $spec.DefaultPortConfig.OutShapingPolicy.averageBandwidth.Value = $outAverageKbps * 1000
         $spec.DefaultPortConfig.OutShapingPolicy.averageBandwidth.Inherited = $false
      }
      if($outBurstKB -ne -1){
         $spec.DefaultPortConfig.OutShapingPolicy.burstSize = New-Object VMware.Vim.LongPolicy
         $spec.DefaultPortConfig.OutShapingPolicy.burstSize.Value = $outBurstKB * 1KB
         $spec.DefaultPortConfig.OutShapingPolicy.burstSize.Inherited = $false
      }
      if($outPeakKbps -ne -1){
         $spec.DefaultPortConfig.OutShapingPolicy.peakBandwidth = New-Object VMware.Vim.LongPolicy
         $spec.DefaultPortConfig.OutShapingPolicy.peakBandwidth.Value = $outPeakKbps * 1000
         $spec.DefaultPortConfig.OutShapingPolicy.peakBandwidth.Inherited = $false
      }
   }
   else{
      $spec.DefaultPortConfig.OutShapingPolicy = New-Object VMware.Vim.DVSTrafficShapingPolicy
      $spec.DefaultPortConfig.OutShapingPolicy.Enabled = New-Object VMware.Vim.BoolPolicy
      $spec.DefaultPortConfig.OutShapingPolicy.Enabled.Value = $false
      $spec.DefaultPortConfig.OutShapingPolicy.Enabled.Inherited = $true
   }

   $dvPg.ReconfigureDVPortgroup($spec)
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
  Foreach ($VirtualPortGroup in Get-VirtualPortGroup -VirtualSwitch $VirtualSwitch|Where {$_.Name -notlike "*DVUplinks*"}) {
      Write "$VirtualPortGroup on $VirtualSwitch"
      $dvPg = Get-dvSwPg -dvSw $VirtualSwitch.ExtensionData -PGName $VirtualPortGroup
      Set-dvPgTrafficShaping -dvPg $dvPg -InShaping -inAverageKbps 10485760 -inBurstKB 102400 -inPeakKbps 10485760 -OutShaping -outAverageKbps 10485760 -outBurstKB 102400 -outPeakKbps 10485760
   }
}
