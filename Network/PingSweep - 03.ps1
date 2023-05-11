Function Test-Subnet {
 
[cmdletbinding()]
 
Param(
[string]$Subnet="172.16.30.0",
[int]$Start = 1,
[int]$End = 254,
[int]$Ping = 1
)
 
Write-Verbose "Testing $subnet"
 
$base = $subnet.split(".")[0..2] -join "."
 
while ($start -le $end) {
  $IP = "$base.$start" 
  Write-Verbose "Pinging $IP" 
  if (Test-Connection -ComputerName $IP -Count $ping -Quiet) {
    $IP
  }
  $start++
}
 
} #end function