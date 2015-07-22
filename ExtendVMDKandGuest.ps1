# PowerCLI Script for adding vmdk to VM and extending disk in windows
# @davidstamen
# http://davidstamen.com

param(
  [string]$VM
)
$VM = Get-VM $VM
$HardDisk = Read-Host "Enter VMware Hard Disk (Ex. 1)"
Get-VM $VM|Get-HardDisk|Select Parent, Name, CapacityGB
$HardDisk = "Hard Disk " + $HardDisk
$HardDiskSize = Read-Host "Enter the new Hard Disk size in GB (Ex. 50)"
$VolumeLetter = Read-Host "Enter the volume letter (Ex. c,d,e,f)"
Get-HardDisk -vm $VM | where {$_.Name -eq $HardDisk} | Set-HardDisk -CapacityGB $HardDiskSize -Confirm:$false
Invoke-VMScript -vm $VM -ScriptText "echo rescan > c:\diskpart.txt && echo select vol $VolumeLetter >> c:\diskpart.txt && echo extend >> c:\diskpart.txt && diskpart.exe /s c:\diskpart.txt" -ScriptType BAT
