$subnet = "172.16.30.0"
$start = 200
$end = 210
$ping = 1
while ($start -le $end) {
$IP = "172.16.30.$start"
Write-Host "Pinging $IP" -ForegroundColor Cyan
Test-Connection -ComputerName $IP -count 1 -Quiet
$start++
}