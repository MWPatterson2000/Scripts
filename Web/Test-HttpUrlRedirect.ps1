param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
)

function Test-HttpUrlRedirect {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Url
    )
    $req = [System.Net.WebRequest]::Create($Url)
    $resp = $req.GetResponse()
    if ($resp.ResponseUri.OriginalString -eq $Url) {
        $false
    }
    else {
        $true
    }
    $resp.Close()
    $resp.Dispose()
}