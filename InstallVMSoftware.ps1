# PowerCLI Script for installing a package to a VM
# @davidstamen
# http://davidstamen.com

param(
  [string]$VMName
)

$VM = Get-VM $VMName

$File = "VMware-v4vdesktopagent-x86_64-6.2.0-3295266.exe"
$Param = "/s /v/qn REBOOT=Reallysuppress"
$SrcPath = "c:\"
$DstPath = "c:\temp\"
$Fullpath = $SrcPath + $File

Write-Host Copying $Fullpath to $VMName
Copy-VMGuestFile -VM $VM -Source $Fullpath -Destination $DstPath -LocalToGuest -Force

$Command = $DstPath + $File + $Param
$Command2 = "del " + $DstPath + $File

Write-Host Executing $Command within guest operating system of $VMName
$Result = Invoke-VMScript -VM $VM  -ScriptText $Command
$ExitCode = $Result.ExitCode
Write-Host $VMName returned exit code $ExitCode

Write-Host Executing $Command2 within guest operating system of $VMName
$Result2 = Invoke-VMScript -VM $VM  -ScriptText $Command2
$ExitCode2 = $Result2.ExitCode
Write-Host $VMName returned exit code $ExitCode2
