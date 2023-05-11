$subnet = "10.0.1"
$start = 1
$end = 254
$ping = 1
while ($start -le $end) {
    #$IP = "192.168.1.$start" 
    $IP = "$subnet.$start"
    $TestResult = Test-Connection -ComputerName $IP -count 1 -Quiet 
    Write-Host ("Pinging", $IP, $TestResult)
    $start++
}