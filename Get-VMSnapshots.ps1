# PowerCLI Script for getting current VM snapshots
# @davidstamen
# http://davidstamen.com

# Connect-VIserver your-vcenter-server -user your-user -password your-password

param($Cluster)  ## Input from command line

if(!($Cluster))
{
    Write-Host -Fore YELLOW "Missing parameter!"
	Write-Host -Fore YELLOW "Usage:"
	Write-Host -Fore YELLOW ".\Get-VMSnapshots.ps1 <your cluster>"
	Write-Host -Fore YELLOW ""
	Write-Host -Fore YELLOW "Example: .\Get-VMSnapshots.ps1 LabCluster"
	exit
}
if(!(Get-Cluster $Cluster -EA SilentlyContinue))
{
	Write-Host -Fore RED "No cluster found with the name: $Cluster "
	Write-Host -Fore YELLOW "These clusters where found in the vCenter you have connected to:"
	Get-Cluster | sort Name | Select Name
	exit
}
Get-Cluster $Cluster|Get-VMHost|Get-VM|Get-Snapshot|Select VM, Name, Created|ft -a
