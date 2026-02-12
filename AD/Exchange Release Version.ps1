function Get-ExchangeReleaseVersion {
    
    # Path to external JSON file
    $jsonPath = Join-Path $PSScriptRoot 'ExchangeVersions.json'
    
    # Load versions from JSON or use embedded data
    $ExchangeVersions = if (Test-Path $jsonPath) {
        Write-Host "Loading Exchange versions from: $jsonPath" -ForegroundColor Green
        Get-Content -Path $jsonPath -Raw | ConvertFrom-Json -AsHashtable
    }
    else {
        Write-Host 'JSON file not found. Using embedded version data.' -ForegroundColor Yellow
        @{}
    }

    function Format-ExchangeVersion {
        param (
            [string]$Version
        )
        
        $versionParts = $Version.Split('.')
        return @{
            MajorVersion = if ($versionParts.Count -ge 2) { $versionParts[0, 1] -join '.' } else { $versionParts[0] }
            FullVersion  = $Version
        }
    }

    function Get-ExchangeVersionDetails {
        try {
            $exchangeServer = Get-ExchangeServer
            $currentVersion = $exchangeServer.AdminDisplayVersion.ToString()
            
            Write-Host "`n========== Exchange Server Details ==========" -ForegroundColor Cyan
            Write-Host "Server Name:`t`t$($exchangeServer.Name)"
            Write-Host "Server FQDN:`t`t$($exchangeServer.Fqdn)"
            Write-Host "Build Number:`t`t$currentVersion"
            Write-Host "Server Role:`t`t$($exchangeServer.ServerRole)"
            Write-Host "Edition:`t`t$($exchangeServer.Edition)"
            Write-Host "============================================`n" -ForegroundColor Cyan
            
            if ($ExchangeVersions.ContainsKey($currentVersion)) {
                $details = $ExchangeVersions[$currentVersion]
                
                Write-Host 'Version Information' -ForegroundColor Green
                Write-Host '==================' -ForegroundColor Green
                Write-Host "Product Version:`t$($details.Name)"
                Write-Host "Release Date:`t`t$($details.ReleaseDate)"
                Write-Host "Security Release:`t$($details.SecurityRelease)"
                Write-Host "Support Status:`t$($details.SupportStatus)"
                if ($details.EndOfSupport) {
                    Write-Host "End of Support:`t`t$($details.EndOfSupport)"
                }
                Write-Host ''
            }
            else {
                Write-Host "Version not found in database: $currentVersion" -ForegroundColor Yellow
                Write-Host ''
            }
            
            # Display all available Exchange versions grouped by product
            Write-Host 'Exchange Version History' -ForegroundColor Yellow
            Write-Host '========================' -ForegroundColor Yellow
            
            $products = @{
                'SE'   = '15.3'
                '2019' = '15.2'
                '2016' = '15.1'
                '2013' = '15.0'
                '2010' = '14.3'
                '2007' = '8.3'
                '2003' = '6.5'
            }
            
            foreach ($product in $products.GetEnumerator() | Sort-Object { [version]$_.Value } -Descending) {
                $productName = $product.Key
                $majorVer = $product.Value
                $versions = $ExchangeVersions.Keys | Where-Object { $_ -like "$majorVer*" } | Sort-Object { [version]$_ } -Descending
                
                if ($versions) {
                    Write-Host "`nExchange Server $productName" -ForegroundColor Cyan
                    foreach ($ver in $versions) {
                        $details = $ExchangeVersions[$ver]
                        $status = if ($details.SecurityRelease) { ' [SEC UPDATE]' } else { '' }
                        Write-Host "  [$ver]$status"
                        Write-Host "    Name: $($details.Name)"
                        Write-Host "    Released: $($details.ReleaseDate) | Status: $($details.SupportStatus)"
                    }
                }
            }

            # Support Lifecycle Summary
            Write-Host "`n`nSupport Lifecycle Summary" -ForegroundColor Magenta
            Write-Host '=========================' -ForegroundColor Magenta
            Write-Host 'Exchange SE: Subscription Based - Always Current (Latest: Jan26SU - 15.3.1750.15)'
            Write-Host 'Exchange 2019: End of Support October 14, 2025 (Latest: Jan26SU - 15.2.1258.34)'
            Write-Host 'Exchange 2016: End of Support October 14, 2025 (Latest: Jan26SU - 15.1.2507.47)'
            Write-Host 'Exchange 2013: End of Support April 11, 2023'
            Write-Host 'Exchange 2010: End of Support October 13, 2020'
            Write-Host 'Exchange 2007: End of Support April 11, 2017'
            Write-Host 'Exchange 2003: End of Support April 8, 2014'
        }
        catch {
            Write-Host "`nError: Unable to get Exchange Server information" -ForegroundColor Red
            Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host 'Make sure you are running this script:'
            Write-Host '1. On an Exchange Server or with Exchange Management Shell'
            Write-Host '2. With appropriate administrative permissions'
            Write-Host '3. In an elevated PowerShell session'
        }
    }

    # Run the version check
    Get-ExchangeVersionDetails
}

# Execute the function
Get-ExchangeReleaseVersion