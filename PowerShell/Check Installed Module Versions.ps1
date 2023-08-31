# Get the Install Module(s) list
#Get-InstalledModule | Sort-Object Name | Select-Object Name, Version, @{n='Online';e={(Find-module -Name $_.Name).Version}} | Format-Table -Autosize

#$Script:ModulesAR = Get-InstalledModule | Select-Object Name, Version, @{ n='Online';e={ (Find-module -Name $_.Name).Version } }
#$Script:ModulesAR = Get-InstalledModule | Sort-Object Name | Select-Object Name, Version, @{n='Online';e={(Find-module -Name $_.Name).Version}}
#$Script:ModulesAR

# Get All Versions of PowerShell Modules Installed
Write-Host "Getting All Versions of PowerShell Module(s) Installed"
$Script:ModulesAR = Get-InstalledModule | Select-Object Name, Version, @{ n='Online';e={ (Find-module -Name $_.Name).Version } } | Sort-Object Name
if (-not $Script:ModulesAR) {
    Write-Host ("`tModules found: 0") -ForegroundColor Yellow
    return
}
else {
    $ModulesCount = $Script:ModulesAR.Count
    $DigitsLength = $ModulesCount.ToString().Length
    Write-Host ("`tModules Found: {0}" -f $ModulesCount) -ForegroundColor Yellow
}

# Find Updated Module(s)
Write-Host "Checking for Updated Versions of Modules"
$i = 0
$count = @($Script:ModulesAR).Count
$count = $count - 1
for ($num = 0 ; $num -le $count ; $num++) {
    $i++
    $Counter = ("[{0,$DigitsLength}/{1,$DigitsLength}]" -f $i, $ModulesCount)
    $CounterLength = $Counter.Length
    #Write-Host "Count:" $num
    #Write-Host "Counter:" $Counter
    #Write-Host ("{0,$CounterLength} Module Count")
    If ($null -eq ($Script:ModulesAR[$num]).Online){
        Write-Host ("{0} Local: {1}`tLocal:{2}`tOnline: None" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version) -ForegroundColor Yellow
        $Script:ModulesAR[$num]
    }
    #if (($Script:ModulesAR[$num]).Version -gt ($Script:ModulesAR[$num]).Online) {
    elseif (($Script:ModulesAR[$num]).Version -gt ($Script:ModulesAR[$num]).Online) {
        #Write-Host "`n" + ($Script:ModulesAR[$num]).Name: + "Online" -ForegroundColor Red
        #$temp = ($Script:ModulesAR[$num]).Name + " - Local Newer"
        #Write-Host $temp -ForegroundColor Yellow
        #Write-Host ("{0} Local Module Newer {1} - {2}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version) -ForegroundColor Yellow
        #Write-Host ("{0} Local Module Newer {1} - Local:{2}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version) -ForegroundColor Yellow
        #Write-Host ("{0} Local: {1}`tLocal:{2}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version) -ForegroundColor Yellow
        Write-Host ("{0} Local: {1}`tLocal:{2}`tOnline:{3}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version) -ForegroundColor Yellow
        $Script:ModulesAR[$num]
    }
    #if (($Script:ModulesAR[$num]).Version -lt ($Script:ModulesAR[$num]).Online) {
    elseif (($Script:ModulesAR[$num]).Version -lt ($Script:ModulesAR[$num]).Online) {
        #Write-Host "`n" + ($Script:ModulesAR[$num]).Name: + "Local" #-ForegroundColor Yellow
        #$temp = ($Script:ModulesAR[$num]).Name + " - Online Newer"
        #Write-Host $temp -ForegroundColor Yellow
        #Write-Host ("{0} Online Module Newer {1} - {2} to {3}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version, ($Script:ModulesAR[$num]).Online) -ForegroundColor Yellow
        #Write-Host ("{0} Online Module Newer {1} - Local:{2} to Online:{3}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version, ($Script:ModulesAR[$num]).Online) -ForegroundColor Yellow
        Write-Host ("{0} Online: {1}`tLocal:{2}`tOnline:{3}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version, ($Script:ModulesAR[$num]).Online) -ForegroundColor Yellow
        $Script:ModulesAR[$num]
    }
}

