#Run this if the server isn’t running as a DC yet, it will create listeners on the common Domain Controllers ports. Close the PowerShell windows to stop the listeners.

$Ports = "464","389","636","3268","3269","53","88","49152"
Foreach ($Port in $Ports) {
    $Endpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Any, $Port)
    $Listener = New-Object System.Net.Sockets.TcpListener $Endpoint
    $Listener.Start()
}

#Run this on a client to check connectivity to the DC (or the server running the script above)

$Target = "servername"
$Ports = "464","389","636","3268","3269","53","88","49152"
Foreach ($Port in $Ports) {
    $Test = (Test-NetConnection $Target -Port $Port)
    if ($Test.TcpTestSucceeded -ne $True) {
        Write-Host “$Target $Port Failed"
    }
    else {
        Write-Host “$Target $Port OK"
    }
}