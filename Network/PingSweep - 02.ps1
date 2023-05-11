Param(
    $subnet = "172.16.30.0",
    $start = 200,
    $end = 210,
    $ping = 1
    )
 
$base = $subnet.split(".")[0..2] -join "."
 
while ($start -le $end) {
    $IP = "$base.$start" 
    Write-Host "Pinging $IP" -ForegroundColor Cyan
    if (Test-Connection -ComputerName $IP -Count $ping -Quiet) {
        $IP
        }
    $start++
    }