function Start-TCPServer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        $Port = 10000
    )
    do {
        # Create a TCP listender on Port $Port
        $TcpObject = New-Object System.Net.Sockets.TcpListener($port)
        # Start TCP listener
        $ReceiveBytes = $TcpObject.Start()
        # Accept TCP client connection
        $ReceiveBytes = $TcpObject.AcceptTcpClient()
        # Stop TCP Client listener
        $TcpObject.Stop()
        # Output information about remote client
        $ReceiveBytes.Client.RemoteEndPoint
    }  while (1)
}
