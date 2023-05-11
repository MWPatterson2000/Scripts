# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
# THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
# FITNESS FOR A PARTICULAR PURPOSE.
#
#
# Script queries port 135 to get the listening ephemeral ports from the remote server
#  and verifies that they are reachable.
#
#
#  Usage:  RPCCheck -Server YourServerNameHere
#
#
#  Note:  The script relies on portqry.exe (from Sysinternals) to get port 135 output.
#  The path to portqry.exe will need to be modified to reflect your location
#
Param(
    [string]$Server
)
#  WORKFLOW QUERIES THE PASSED ARRAY OF PORTS TO DETERMINE STATUS
workflow Check-Port {
    param ([string[]]$RPCServer, [array]$arrRPCPorts)
    $comp = hostname

    ForEach -parallel ($RPCPort in $arrRPCPorts) {
        $bolResult = InlineScript { Test-NetConnection -ComputerName $Using:RPCServer -port $Using:RPCPort _
            -InformationLevel Quiet }
        If ($bolResult) {
            Write-Output "$RPCPort on $RPCServer is reachable"
        }
        Else {
            Write-Output "$RPCPort on $RPCServer is unreachable"
        }
    }
}
#  INITIAL RPC PORT
$strRPCPort = "135"
#  MODIFY PATH TO THE PORTQRY BINARY IF NECESSARY
$strPortQryPath = "C:\Sysinternals"
#  TEST THE PATH TO SEE IF THE BINARY EXISTS
If (Test-Path "$strPortQryPath\PortQry.exe") {
    $strPortQryCmd = "$strPortQryPath\PortQry.exe -e $strRPCPort -n $Server"
}
Else {
    Write-Output "Could not locate Portqry.exe at the path $strPortQryPath"
    Exit
}
#  CREATE AN EMPTY ARRAY TO HOLD THE PORTS RETURNED FROM THE RPC PORTMAPPER
$arrPorts = @()
#  RUN THE PORTQRY COMMAND TO GET THE EPHEMERAL PORTS
$arrQuryResult = Invoke-Expression $strPortQryCmd
# CREATE AN ARRAY OF THE PORTS
ForEach ($strResult in $arrQuryResult) {
    If ($strResult.Contains("ip_tcp")) {
        $arrSplt = $strResult.Split("[")
        $strPort = $arrSplt[1]
        $strPort = $strPort.Replace("]", "")
        $arrPorts += $strPort
    }
}
#  DE-DUPLICATE THE PORTS
$arrPorts = $arrPorts | Sort-Object | Select-Object -Unique
#  EXECUTE THE WORKFLOW TO CHECK THE PORTS
Check-Port -RPCServer $Server -arrRPCPorts $arrPorts