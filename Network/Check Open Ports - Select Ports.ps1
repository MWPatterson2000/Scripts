# Taken from https://www.blackhillsinfosec.com/poking-holes-in-the-firewall-egress-testing-with-allports-exposed/

# Test Select Ports
21,22,23,25,80,443,1337 | ForEach-Object {$test= new-object system.Net.Sockets.TcpClient; $wait =$test.beginConnect("allports.exposed",$_,$null,$null); ($wait.asyncwaithandle.waitone(250,$false)); if($test.Connected){Write-Output "$_ open"}else{Write-Output "$_ closed"}} | select-string " "
