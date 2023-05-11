$tempAR = Get-VM | Where-Object {$_.Name -Like "Win 10 Pro*"}
foreach ($vm in $tempAR) {
    #Write-Host ($vm).Name
    if (($vm).Name -like "*01") {}
    elseif (($vm).Name -like "*02") {}
    elseif (($vm).Name -like "*03") {}
    elseif (($vm).Name -like "*04") {}
    elseif (($vm).Name -like "*05") {}
    else {
        Write-Host "Changing AutoStart for VM:"($vm).Name -ForegroundColor Green
        Set-VM -Name ($vm).Name -AutomaticStartAction Nothing
    }
}