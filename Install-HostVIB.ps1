# PowerCLI Script for installing a VIB to a host
# @davidstamen
# http://davidstamen.com

# Define Variables
$Cluster = "Cluster"
$VIBPATH = "/vmfs/volumes/NFS01/VIB/cisco/scsi-fnic_1.6.0.24-1OEM.600.0.0.2494585.vib"
$vcenter = "vcenter.lab.local"
$cred = Get-Credential

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

    Write-host "Preparing $($_.Name) for ESXCLI" -ForegroundColor Yellow

    $ESXCLI = Get-EsxCli -VMHost $_ -V2

    # Install VIBs
    Write-host "Installing VIB on $($_.Name)" -ForegroundColor Yellow
		
		# Create Installation Arguments
		$insParm = @{
			viburl = $viburl
			dryrun = $false
			nosigcheck = $true
			maintenancemode = $false
			force = $false
		}
	
	$action = $ESXCLI.software.vib.install.Invoke($insParm)

    # Verify VIB installed successfully
    if ($action.Message -eq "Operation finished successfully."){Write-host "Action Completed successfully on $($_.Name)" -ForegroundColor Green} else {Write-host $action.Message -ForegroundColor Red}
}
