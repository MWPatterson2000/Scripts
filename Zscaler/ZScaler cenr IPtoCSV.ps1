<#
Name: ZScaler cenr IPtoCSV.ps1

This script will download a JSON from zscaler and export the data to a CSV file.

This script will create file(s) (Either of these are an option)
    ZScaler - $zenscalerType - $zenscalerHost<Year>-<Month>-<Date>-<Hour>-<Minuite>.csv     - This contains the list of the data from the JSON in a CSV
    ZScaler - $zenscalerType - $zenscalerHost.csv                                           - This contains the list of the data from the JSON in a CSV


Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-01-10 - Initial Release

#>
# Clear Screen
Clear-Host

# Variables
# Get Date & Data Locations
$date = $(Get-Date -Format yyyy-MM-dd-HH-mm)
$dataRoot = "C:" #Can use another drive if available
$dataFolder = "Temp"

# URL
$zenscalerHost = "zscalerthree.net"
$zenscalerType = "cenr"
$url = "https://api.config.zscaler.com/$zenscalerHost/$zenscalerType/json"

# Download JSON File
$ipList = Invoke-WebRequest -Uri $url | ConvertFrom-Json

# Create User Table(s)
$ipAddressList = [System.Collections.ArrayList]::new()

# Loop through JSON Data
foreach ($dnsHost in $ipList.psobject.properties.name) {
    foreach ($continent in $ipList.$dnsHost.psobject.properties.name) {
        foreach ($city in $ipList.$dnsHost.$continent.psobject.properties.name) {
            $cityList = $ipList.$dnsHost.$continent.$city | `
                Select-Object @{n = 'DNSHost'; e = { ($dnsHost -split ':')[-1].Trim() } }, @{n = 'Continent'; e = { ($continent -split ':')[-1].Trim() } }, @{n = 'City'; e = { ($city -split ':')[-1].Trim() } }, *
            foreach ($cityObj in $cityList) {
                $count = @($cityObj).Count
                If ($count -eq 0) {}
                elseif ($count -eq 1) {
                    $ipAddressT = @{}
                    $ipAddressT | Add-Member -type noteproperty -Name 'DNS Host' -Value $cityObj.DNSHost
                    $ipAddressT | Add-Member -type noteproperty -Name 'Continent' -Value $cityObj.Continent
                    $ipAddressT | Add-Member -type noteproperty -Name 'City' -Value $cityObj.City
                    $ipAddressT | Add-Member -type noteproperty -Name 'range' -Value $cityObj.range
                    $ipAddressT | Add-Member -type noteproperty -Name 'vpn' -Value $cityObj.vpn
                    $ipAddressT | Add-Member -type noteproperty -Name 'gre' -Value $cityObj.gre
                    $ipAddressT | Add-Member -type noteproperty -Name 'hostname' -Value $cityObj.hostname
                    $ipAddressT | Add-Member -type noteproperty -Name 'latitude' -Value $cityObj.latitude
                    $ipAddressT | Add-Member -type noteproperty -Name 'longitude' -Value $cityObj.longitude
                    #$ipAddressT | Add-Member -type noteproperty -Name '' -Value $user.
                    # Add Data to Table
                    [void]$ipAddressList.Add($ipAddressT)
                }
            }
        }
    }
}

# CSV File
$zscaler = "$dataRoot\$dataFolder\ZScaler - $zenscalerType - $zenscalerHost.csv"
#$zscaler = "$dataRoot\$dataFolder\ZScaler - $zenscalerType - $zenscalerHost - $date.csv"

# Export Combined User List
$ipAddressList | Select-Object 'DNS Host', Continent, City, range, vpn, gre, hostname, latitude, longitude | `
    Export-Csv -Path $zscaler -Encoding utf8 -NoTypeInformation

# End
