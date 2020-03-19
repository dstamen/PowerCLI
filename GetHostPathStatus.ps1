Get-VMHost | Sort-Object -property Name | ForEach-Object {
  $VMHost = $_
  $VMHost | Get-VMHostHba | Sort-Object -property Device | ForEach-Object {
    $VMHostHba = $_
    $ScsiLun = $VMHostHba | Get-ScsiLun
    If ($ScsiLun) {
      $ScsiLunPath = $ScsiLun | Get-ScsiLunPath | `
        Where-Object {$_.Name -like "$($VMHostHba.Device)*"}
      $Targets = ($ScsiLunPath | `
        Group-Object -Property SanID | Measure-Object).Count
      $Devices = ($ScsiLun | Measure-Object).Count
      $Paths = ($ScsiLunPath | Measure-Object).Count
    }
    Else {
      $Targets = 0
      $Devices = 0
      $Paths = 0
    }
    $Report = "" | Select-Object -Property VMHost,HBA,Targets,Devices,Paths
    $Report.VMHost = $VMHost.Name
    $Report.HBA = $VMHostHba.Device
    $Report.Targets = $Targets
    $Report.Devices = $Devices
    $Report.Paths = $Paths
    $Report
  }
}