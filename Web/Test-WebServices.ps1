param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
)

## Parse host from URL
$hostname = $url.split('/')[2]

if (-not (Test-NetConnection -ComputerName $hostname -CommonTCPPort HTTP).TcpTestSucceeded) { 
    $false
} else {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    if ($response.StatusCode -ne 200) {
        $false
    } else {
        $true
    }
}
