#requires -version 4.0
#requires -module NetTCPIP

Function Test-Subnet {

  [cmdletbinding()]
  Param(
    [Parameter(Position = 0, HelpMessage = "Enter an IPv4 subnet ending in 0.")]
    [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.0")]
    [string]$Subnet = ((Get-NetIPAddress -AddressFamily IPv4).Where({ $_.InterfaceAlias -notmatch "Bluetooth|Loopback" }).IPAddress -replace "\d{1,3}$", "0"),

    [ValidateRange(1, 254)]
    [int]$Start = 1,

    [ValidateRange(1, 254)]
    [int]$End = 254,

    [ValidateRange(1, 10)]
    [Alias("count")]
    [int]$Ping = 1
  )

  Write-Verbose "Pinging $subnet from $start to $end"
  Write-Verbose "Testing with $ping pings(s)"

  #a hash table of parameter values to splat to Write-Progress
  $progHash = @{
    Activity         = "Ping Sweep"
    CurrentOperation = "None"
    Status           = "Pinging IP Address"
    PercentComplete  = 0
  }

  #How many addresses need to be pinged?
  $count = ($end - $start) + 1

  <#
take the subnet and split it into an array then join the first
3 elements back into a string separated by a period.
This will be used to construct an IP address.
#>

  $base = $subnet.split(".")[0..2] -join "."

  #Initialize a counter
  $i = 0

  #loop while the value of $start is <= $end
  while ($start -le $end) {
    #increment the counter

    $i++
    #calculate % processed for Write-Progress
    $progHash.PercentComplete = ($i / $count) * 100

    #define the IP address to be pinged by using the current value of $start
    $IP = "$base.$start" 

    #Use the value in Write-Progress
    $proghash.currentoperation = $IP
    Write-Progress @proghash

    #test the connection
    if (Test-Connection -ComputerName $IP -Count $ping -Quiet) {
      #write the pingable address to the pipeline if it responded
      $IP
    } #if test ping

    #increment the value $start by 1
    $start++
  } #close while loop

} #end function