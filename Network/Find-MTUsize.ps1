function Global:Find-MTU {
    <#

    .SYNOPSIS
        Sends ICMPv4 echo request packets to a given IPv4 address 
        with various payload sizes until the maximum transmission unit is found.

    .DESCRIPTION
        Inspired by the script of Charles_1.0 I created a function that uses 
        the .Net ping class to find the biggest transmission unit size.
        It simple and fast.  
        Just open Powershell, run the script and type Find-MTU <ipaddress> to get the result.

    .INPUTS
        None
        You cannot pipe input to this cmdlet.

    .OUTPUTS
        The function returns an integer that represents the MTU size.
    
    .NOTES 
        Author: G.A.F.F. Jakobs 
        Version: 1.3

    .EXAMPLE
        Find-MTU 192.168.1.254

    .LINK
        http://gallery.technet.microsoft.com/Find-the-Biggest-MTU-size-ff1c6069

    #>

    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    Param(
        [parameter(Mandatory = $true, Position = 0)]
        [System.Net.IPAddress]$IPaddress
    )

    $Ping = New-Object System.Net.NetworkInformation.Ping
    $PingOptions = New-Object System.Net.NetworkInformation.PingOptions
    $PingOptions.DontFragment = $true

    [int]$Timeout = 1000
    [int]$SmallMTU = 1
    [int]$LargeMTU = 35840

    [byte[]]$databuffer = , 0xAC * $LargeMTU


    #action

    While (-not ($SmallMTU -eq ($LargeMTU - 1))) {
        [int]$xTest = ($LargeMTU - $SmallMTU) / 2 + $SmallMTU
		
        $PingReply = $Ping.Send($IPaddress, $Timeout, $($DataBuffer[1..$xTest]), $PingOptions)
        Write-Verbose "testing $($xTest + 28) byte transmission unit size" 
        if ($PingReply.Status -match "Success") {	
            $SmallMTU = $xTest
        }
        else {
            $LargeMTU = $xTest
        }
        Start-Sleep -Milliseconds 50
    }
    
    If ($SmallMTU -eq 1) {
        Write-Error "The IP address $IPaddress does not respond." 
    }
    else {
        return $SmallMTU + 28 # add 28 bytes because 20 bytes are reserved for the IP header and 8 bytes must be allocated for the ICMP Echo Request header.
    }
}