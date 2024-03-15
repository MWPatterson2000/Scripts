$StartDate=(GET-DATE)
Start-Sleep -Seconds 62
$EndDate=(GET-DATE)
NEW-TIMESPAN –Start $StartDate –End $EndDate | Select-Object Minutes, Seconds
#([timespan]NEW-TIMESPAN –Start $StartDate –End $EndDate).TotalSeconds


#$Duration=$EndDate-$StartDate
#Write-host $Duration
#Write-host $Duration


$stopwatch = New-Object System.Diagnostics.Stopwatch
$stopwatch.Start()
Start-Sleep -Seconds 62
$stopwatch.Stop()
$stopwatch

