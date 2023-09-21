# Get All Versions of PowerShell Modules Installed
Write-Host "Getting All Versions of PowerShell Module(s) Installed"
$Script:ModulesAR = Get-InstalledModule | Select-Object Name, Version, @{ n = 'Online'; e = { (Find-module -Name $_.Name).Version } } | Sort-Object Name
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
    If ($null -eq ($Script:ModulesAR[$num]).Online) {
        #Write-Host ("{0} Local: {1}`tLocal:{2}`tOnline: None" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version) -ForegroundColor Yellow
        $Script:ModulesAR[$num]
    }
    #if (($Script:ModulesAR[$num]).Version -gt ($Script:ModulesAR[$num]).Online) {
    elseif (($Script:ModulesAR[$num]).Version -gt ($Script:ModulesAR[$num]).Online) {
        #Write-Host ("{0} Local: {1}`tLocal:{2}`tOnline:{3}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version) -ForegroundColor Yellow
        $Script:ModulesAR[$num]
    }
    #if (($Script:ModulesAR[$num]).Version -lt ($Script:ModulesAR[$num]).Online) {
    elseif (($Script:ModulesAR[$num]).Version -lt ($Script:ModulesAR[$num]).Online) {
        #Write-Host ("{0} Online: {1}`tLocal:{2}`tOnline:{3}" -f $Counter, ($Script:ModulesAR[$num]).Name, ($Script:ModulesAR[$num]).Version, ($Script:ModulesAR[$num]).Online) -ForegroundColor Yellow
        $Script:ModulesAR[$num]
    }
}

