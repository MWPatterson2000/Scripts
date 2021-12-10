# Get the Install Module(s) list
#Get-Installedmodule | Sort-Object Name | Select-Object Name, Version, @{n='Online';e={(Find-module -Name $_.Name).Version}} | Format-Table -Autosize

$tempAR = Get-Installedmodule | Select-Object Name, Version, @{n='Online';e={(Find-module -Name $_.Name).Version}}
#$tempAR = Get-Installedmodule | Sort-Object Name | Select-Object Name, Version, @{n='Online';e={(Find-module -Name $_.Name).Version}}
#$tempAR

# Find Updated Module(s)
$count = @(($tempAR).Name).Count
$count = $count - 1
for ($num = 0 ; $num -le $count ; $num++) {
    if (($tempAR[$num]).Version -gt ($tempAR[$num]).Online) {
        #Write-Host "`n" + ($tempAR[$num]).Name: + "Online" -ForegroundColor Red
        $temp = ($tempAR[$num]).Name + " - Online Newer"
        Write-Host $temp -ForegroundColor Yellow
        $tempAR[$num]
    }
    if (($tempAR[$num]).Version -lt ($tempAR[$num]).Online) {
        #Write-Host "`n" + ($tempAR[$num]).Name: + "Local" #-ForegroundColor Yellow
        $temp = ($tempAR[$num]).Name + " - Local Newer"
        Write-Host $temp -ForegroundColor Yellow
        $tempAR[$num]
     }
}


