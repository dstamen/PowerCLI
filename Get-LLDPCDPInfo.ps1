#########################################################################################################
##  LLDP_CDP_Information.ps1
##  Version 1.0
##  Auxilium Technology AS, November 2014
##  http://www.auxilium.no
##
##  Description:
##  Sometimes it's useful to know which ports your host(s) are connected to.  It's also good to know what
##  kind of switch you have to deal with and if possible, get the firmware version.
##
##  Script created 20.11.2014
##  Bjørn-Ove Kiil  (bok@auxilium.no)
##
##  Requirement:
##  The switches where your host(s) are connected have to support Link Layer Discovery Protocol (LLDP) or
##  Cisco Discovery Protocol (CDP) and this feature must be enabled in order to get any information out
##  of it.
##  PS! LLDP is only available on host(s) which are a member of a Distributed Virtual Switch!!
##
##  Usage:
##  .\LLDP_CDP_Information.ps1 <Clustername>
##
##  Ex.: .\LLDP_CDP_Information.ps1 LabCluster
##
#########################################################################################################

# Connect-VIserver your-vcenter-server -user your-user -password your-password

param($Cluster)  ## Input from command line

if(!($Cluster))
{
    Write-Host -Fore YELLOW "Missing parameter!"
	Write-Host -Fore YELLOW "Usage:"
	Write-Host -Fore YELLOW ".\LLDP_CDP_Information.ps1 <your cluster>"
	Write-Host -Fore YELLOW ""
	Write-Host -Fore YELLOW "Example: .\LLDP_CDP_Information.ps1 LabCluster"
	exit
}
if(!(Get-Cluster $Cluster -EA SilentlyContinue))
{
	Write-Host -Fore RED "No cluster found with the name: $Cluster "
	Pause
	Write-Host -Fore YELLOW "These clusters where found in the vCenter you have connected to:"
	Get-Cluster | sort Name | Select Name
	exit
}

$vmh =  Get-Cluster $Cluster | Get-VMHost | sort name
$LLDPResultArray = @()
$CDPResultArray = @()

If ($vmh.ConnectionState -eq "Connected" -or $vmh.State -eq "Maintenance")
{
   Get-View $vmh.ID | `
   % { $esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem} | `
   % { foreach ($physnic in $_.NetworkInfo.Pnic) {
     $pnicInfo = $_.QueryNetworkHint($physnic.Device)

    foreach( $hint in $pnicInfo )
	{
	  ## If the switch support LLDP, and you're using Distributed Virtual Swicth with LLDP
	  if ($hint.LLDPInfo)
	  {
		#$hint.LLDPInfo.Parameter
		$LLDPResult = "" | select-object VMHost, PhysicalNic, PhysSW_Port, PhysSW_Name, PhysSW_Description, PhysSW_MGMTIP, PhysSW_MTU

		$LLDPResult.VMHost = $esxname
		$LLDPResult.PhysicalNic = $physnic.Device
		$LLDPResult.PhysSW_Port = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "Port Description" }).Value
		$LLDPResult.PhysSW_Name = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "System Name" }).Value
		$LLDPResult.PhysSW_Description = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "System Description" }).Value
		$LLDPResult.PhysSW_MGMTIP = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "Management Address" }).Value
		$LLDPResult.PhysSW_MTU = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "MTU" }).Value

		$LLDPResultArray += $LLDPResult
       }

	  ## If it's a Cisco switch behind the server ;)
	  if ($hint.ConnectedSwitchPort)
	  {
		#$hint.ConnectedSwitchPort
		$CDPResult = "" | select-object VMHost, PhysicalNic, PhysSW_Port, PhysSW_Name, PhysSW_HWPlatform, PhysSW_Software, PhysSW_MGMTIP, PhysSW_MTU

		$CDPResult.VMHost = $esxname
		$CDPResult.PhysicalNic = $physnic.Device
		$CDPResult.PhysSW_Port = $hint.ConnectedSwitchPort.PortID
		$CDPResult.PhysSW_Name = $hint.ConnectedSwitchPort.DevID
		$CDPResult.PhysSW_HWPlatform = $hint.ConnectedSwitchPort.HardwarePlatform
		$CDPResult.PhysSW_Software = $hint.ConnectedSwitchPort.SoftwareVersion
		$CDPResult.PhysSW_MGMTIP = $hint.ConnectedSwitchPort.MgmtAddr
		$CDPResult.PhysSW_MTU = $hint.ConnetedSwitchPort.Mtu

		$CDPResultArray += $CDPResult
	  }
	  if(!($hint.LLDPInfo) -and (!($hint.ConnectedSwitchPort)))
	  {
		Write-Host -Fore YELLOW "No CDP or LLDP information available! "
		Write-Host -Fore YELLOW "Check if your switches support these protocols and if"
		Write-Host -Fore YELLOW "the CDP/LLDP features are enabled."
	  }
	}
    }
   }
}

else
{
	Write-Host "No host(s) found in Connected or Maintenance state!"
	exit
}

## Output to screen and/or file
if ($CDPResultArray)
{
	$CDPResultArray | ft -autosize
	$CDPResultArray | Export-Csv .\CDP_Info_$Cluster.txt -useculture -notypeinformation
}
if ($LLDPResultArray)
{
	$LLDPResultArray | ft -autosize
	$LLDPResultArray | Export-Csv .\LLDP_Info_$Cluster.txt -useculture -notypeinformation
}

#disconnect-viserver * -Confirm:$false
