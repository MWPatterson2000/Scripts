
$volumes = Get-WmiObject win32_volume -computername localhost -Filter "DriveType='3'"
$volumes | Select-Object SystemName, Name, Label, DriveLetter, FileSystem,  `
    @{Name="Capacity(GB)";expression={[math]::round(($_.Capacity/ 1073741824),2)}}, `
    @{Name="Free Space(GB)";expression={[math]::round(($_.FreeSpace / 1073741824),2)}}, `
    @{Name="Used Space(GB)";expression={[math]::round((($_.Capacity / 1073741824)-($_.FreeSpace / 1073741824)),2)}}, `
    @{Name="Free(%)";expression={[math]::round(((($_.FreeSpace / 1073741824)/($_.Capacity / 1073741824)) * 100),2)}} `
    | Sort-Object SystemName, DriveLetter, Name | Format-Table -AutoSize
#     | Sort-Object DriveLetter, Name | Export-csv "c:\Temp\Test.csv" -NoTypeInformation
