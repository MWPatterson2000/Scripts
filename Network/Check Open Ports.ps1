# Taken from https://www.blackhillsinfosec.com/poking-holes-in-the-firewall-egress-testing-with-allports-exposed/

# Test Ports 1-1024
1..1024 | ForEach-Object {$test= new-object system.Net.Sockets.TcpClient; $wait = $test.beginConnect("allports.exposed",$_,$null,$null); ($wait.asyncwaithandle.waitone(250,$false)); if($test.Connected){Write-Output "$_ open"}else{Write-Output "$_ closed"}} | select-string " "

# Test Select Ports
21,22,23,25,80,443,1337 | ForEach-Object {$test= new-object system.Net.Sockets.TcpClient; $wait =$test.beginConnect("allports.exposed",$_,$null,$null); ($wait.asyncwaithandle.waitone(250,$false)); if($test.Connected){Write-Output "$_ open"}else{Write-Output "$_ closed"}} | select-string " "

# Test Top 128 Ports
80,23,443,21,22,25,3389,110,445,139,143,53,135,3306,8080,1723,111,995,993,5900,1025,587,8888,199,1720,465,548,113,81,6001,10000,514,5060,179,1026,2000,8443,8000,32768,554,26,1433,49152,2001,515,8008,49154,1027,5666,646,5000,5631,631,49153,8081,2049,88,79,5800,106,2121,1110,49155,6000,513,990,5357,427,49156,543,544,5101,144,7,389,8009,3128,444,9999,5009,7070,5190,3000,5432,3986,13,1029,9,6646,49157,1028,873,1755,2717,4899,9100,119,37,1000,3001,5001,82,10010,1030,9090,2107,1024,2103,6004,1801,19,8031,1041,255,3703,17,808,3689,1031,1071,5901,9102,9000,2105,636,1038,2601,7000 | ForEach-Object {$test= new-object system.Net.Sockets.TcpClient; $wait =$test.beginConnect("allports.exposed",$_,$null,$null); ($wait.asyncwaithandle.waitone(250,$false)); if($test.Connected){Write-Output "$_ open"}else{Write-Output "$_ closed"}} | select-string " "

