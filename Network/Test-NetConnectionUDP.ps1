function Test-NetConnectionUDP {
    [CmdletBinding()]
    param (
        # Desit
        [Parameter(Mandatory = $true)]
        [int32]$Port,

        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [int32]$SourcePort = 50000
    )

    begin {
        # Create a UDP client object
        $UdpObject = New-Object system.Net.Sockets.Udpclient($SourcePort)
        # Define connect parameters
        $UdpObject.Connect($ComputerName, $Port)
    }

    process {
        # Convert current time string to byte array
        $ASCIIEncoding = New-Object System.Text.ASCIIEncoding
        $Bytes = $ASCIIEncoding.GetBytes("$(Get-Date -UFormat "%Y-%m-%d %T")")
        # Send data to server
        [void]$UdpObject.Send($Bytes, $Bytes.length)
    }

    end {
        # Cleanup
        $UdpObject.Close()
    }
}
