param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Url
)

# Check Web Status
# Measure Time to Get URL
$response = (Measure-Command -Expression { $site = Invoke-WebRequest -Uri $url -UseBasicParsing })
If ($site.StatusCode -eq 200) {
    Write-Host "The following URL is Responding:" $Url
    Write-Host "The Site Responded in (MS):" ($response).Milliseconds
}
else {
    Write-Host "The following URL is Not Responding: $Url"
}
