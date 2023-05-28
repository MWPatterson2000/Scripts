$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'"
$volumes | Select-Object Name, Label, DriveLetter, FileSystem,  `
    @{Name="Capacity(GB)";expression={[math]::round(($_.Capacity/ 1073741824),2)}}, `
    @{Name="Used Space(GB)";expression={[math]::round((($_.Capacity / 1073741824)-($_.FreeSpace / 1073741824)),2)}}, 
    @{Name="Free Space(GB)";expression={[math]::round(($_.FreeSpace / 1073741824),2)}}, `
    @{Name="Free(%)";expression={[math]::round(((($_.FreeSpace / 1073741824)/($_.Capacity / 1073741824)) * 100),2)}} `
    | Sort-Object DriveLetter, Name | ConvertTo-Html  -Head $Header | Out-File -FilePath "C:\temp\HardDrives.html"

