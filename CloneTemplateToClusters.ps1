# PowerCLI Script For Cloning Templates to Multiple Datastores
# @davidstamen
# http://davidstamen.com

#Import PowerCLI Module
Add-PSSnapin VMware.VimAutomation.Core

#Define Variables
$Credential = Get-Credential
$vCenter = "vcenter.lab.local"
$clusters = "Cluster01","Cluster02"
$location = "Templates"
$templates = "Template1","Template2"

#Connect to vCenter
Connect-VIServer $vCenter -Credential $Credential

foreach ($template in $templates){
  foreach ($cluster in $clusters){
    #Check if Template exists
    Try{Get-Template $template-$cluster -ErrorAction Stop;$TemplateExists = $true}Catch {$TemplateExists = $false}
    #Create VM
    If($TemplateExists -eq $true){
        #Remove Old Template
        Get-Template -Name $template-$cluster |Remove-Template -DeletePermanently -Confirm:$false
        #Clone the Template
        New-VM -Name $template-$cluster -Template $template -ResourcePool $cluster -Datastore $cluster-DSC -Location $location
        #Convert to Template
        Set-VM -VM $template-$cluster -ToTemplate -Confirm:$false
    }
    ElseIf($TemplateExists -eq $false){
        #Clone the Template
        New-VM -Name $template-$cluster -Template $template -ResourcePool $cluster -Datastore $cluster-DSC -Location $location
        #Convert to Template
        Set-VM -VM $template-$cluster -ToTemplate -Confirm:$false
    }
  }
}
#Disconnect from vCenter
Disconnect-VIServer $vCenter -Force -Confirm:$false
