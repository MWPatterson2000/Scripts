# ----------------------------------- Script Start from here ------------
param(
[string]$Servername="localhost"
)
#Please Make sure that the tool is in the path below or simply update the path 
if (Test-Path "C:\Tools"){
    Try{
   #Execute the tool and filter the output to get only the IP unique result 
        $RPCPorts=  C:\Tools\PortQry.exe -e 135 -n $Servername  | findstr "ncacn_ip" | Select-Object -Unique
            if ($RPCPorts.length -eq 0){
                Write-Host "No output, maybe incorrect server name" -ForegroundColor Red
                return
            }
        #Parsing the output
        ForEach ($SinglePort in $RPCPorts){
        $porttocheck=$SinglePort.Substring($SinglePort.IndexOfAny("[")+1)
        $porttocheck=$porttocheck.Remove($porttocheck.Length -1)
        #Checking the port reachability 
        $Result=Test-NetConnection -ComputerName $Servername -Port $porttocheck
        Write-Host "Port health for $Servername on port $porttocheck is " -NoNewline
        Write-Host $Result.TcpTestSucceeded -ForegroundColor Green
        }
    }
    Catch{
        #Something went wrong, maybe the firewall block, the exception will be written
        Write-Host $_.Exception.Message -ForegroundColor Red

    }

}
ELSE{
    Write-Host "PortQry is not found"
}
# --------------------------------- Script Finishes here ------------