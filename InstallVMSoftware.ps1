# PowerCLI Script for installing a package to a VM
# @davidstamen
# http://davidstamen.com

#Define Variables
Write-Host "Prompt For Guest Credentials" -ForegroundColor Yellow
$Cred = Get-Credential
$VMs = "VM1","VM2"
#$VMs = Get-VM VM* | Sort Name

Foreach ($VMName in $VMs) {
  $VM = Get-VM $VMName

#Define file information. Include File Name, Parameters, Source and Destination
  $File = "VMware-v4vdesktopagent-x86_64-6.2.0-3295266.exe"
  $Param = "/s /v/qn REBOOT=Reallysuppress"
  $SrcPath = "c:\"
  $DstPath = "c:\temp\"
  $Fullpath = $SrcPath + $File

  Write-Host Copying $Fullpath to $VMName -ForegroundColor Cyan
  Copy-VMGuestFile -VM $VM -Source $Fullpath -Destination $DstPath -LocalToGuest -GuestCredential $Cred -Force

  #Define Install File Command
  $Command = $DstPath + $File + $Param
  #Define Delete File Command
  $Command2 = "del " + $DstPath + $File

  Write-Host Executing $Command within guest operating system of $VMName -ForegroundColor White
  $Result = Invoke-VMScript -VM $VM  -ScriptText $Command -GuestCredential $Cred
  $ExitCode = $Result.ExitCode
  if ($ExitCode = "0") {
    Write-Host $VMName returned exit code $ExitCode -ForegroundColor Green
  }
  Else {
    Write-Host $VMName returned exit code $ExitCode -ForegroundColor Red
  }
  Write-Host Executing $Command2 within guest operating system of $VMName -ForegroundColor White
  $Result2 = Invoke-VMScript -VM $VM  -ScriptText $Command2 -GuestCredential $Cred
  $ExitCode2 = $Result2.ExitCode
  if ($ExitCode2 = "0") {
    Write-Host $VMName returned exit code $ExitCode2 -ForegroundColor Green
  }
  Else {
    Write-Host $VMName returned exit code $ExitCode2 -ForegroundColor Red
  }
}
