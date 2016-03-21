# PowerCLI Script for View to Check the Last View Broker logon per User
# @davidstamen
# http://davidstamen.com

#Define Variables
#$StartDate = "01/01/2016" #uncomment to look by a range of dates
#$EndDate = Get-Date #uncomment to look by a range of dates
$EventType = "BROKER_USERLOGGEDIN"
#$Events = Get-EventReport -ViewName user_events -StartDate $StartDate -EndDate $EndDate|Where-Object {$_.eventtype -eq $EventType}|Select userdisplayname,time #uncomment to look by a range of dates
$Events = Get-EventReport -ViewName user_events|Where-Object {$_.eventtype -eq $EventType}|Select userdisplayname,time
$Users = $Events.userdisplayname|Select-Object -Uniq

#Find Last Logon
Foreach ($User in $Users){
  $Result = $Events|Where-Object {$_.userdisplayname -eq $User}|Select-Object -Last 1|select userdisplayname,time
  if ($Result -eq $null) {Write-Host $User " has no current logon"}
  else {
    Write-Host $User "had a last logon on" $Result.time}
}
