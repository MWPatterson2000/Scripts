# Reference: https://learn.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates

function Get-ExchangeReleaseVersion {
    # Create comprehensive version mapping
    $ExchangeVersions = @{
        # Exchange Server Subscription Edition (SE)
        '15.3.1750.13' = @{
            Name            = 'Exchange Server SE CU1 Oct25SU'
            ReleaseDate     = '2025-10-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5039689'
            SupportStatus   = 'Current'
            Description     = 'October 2025 Security Update'
        }
        '15.3.1750.12' = @{
            Name            = 'Exchange Server SE CU1 Jul25SU'
            ReleaseDate     = '2025-07-09'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5038797'
            SupportStatus   = 'Current'
        }
        '15.3.1750.8'  = @{
            Name            = 'Exchange Server SE CU1'
            ReleaseDate     = '2025-04-08'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5037989'
            SupportStatus   = 'Current'
        }
        '15.3.1544.10' = @{
            Name            = 'Exchange Server SE RTM'
            ReleaseDate     = '2024-03-12'
            SecurityRelease = $false
            UpdateType      = 'RTM'
            KB              = 'N/A'
            SupportStatus   = 'Current'
            Description     = 'Initial Release'
        }

        # Exchange Server 2019
        '15.2.1258.32' = @{
            Name            = 'Exchange Server 2019 CU15 Oct25SU'
            ReleaseDate     = '2025-10-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5039688'
            SupportStatus   = 'Mainstream Support'
            EndOfSupport    = '2025-10-14'
            Description     = 'October 2025 Security Update'
        }
        '15.2.1258.25' = @{
            Name            = 'Exchange Server 2019 CU15 Jul25SU'
            ReleaseDate     = '2025-07-09'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5038796'
            SupportStatus   = 'Mainstream Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.2.1258.20' = @{
            Name            = 'Exchange Server 2019 CU15 Apr25SU'
            ReleaseDate     = '2025-04-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5037988'
            SupportStatus   = 'Mainstream Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.2.1258.16' = @{
            Name            = 'Exchange Server 2019 CU15 Mar24SU'
            ReleaseDate     = '2024-03-12'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5035849'
            SupportStatus   = 'Mainstream Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.2.1258.12' = @{
            Name            = 'Exchange Server 2019 CU15'
            ReleaseDate     = 'February 13, 2024'
            SecurityRelease = $true
        }
        '15.2.1258.10' = @{
            Name            = 'Exchange Server 2019 CU15'
            ReleaseDate     = 'January 9, 2024'
            SecurityRelease = $true
        }
        '15.2.1118.30' = @{
            Name            = 'Exchange Server 2019 CU14'
            ReleaseDate     = 'February 13, 2024'
            SecurityRelease = $true
        }
        '15.2.1118.26' = @{
            Name            = 'Exchange Server 2019 CU14'
            ReleaseDate     = 'January 9, 2024'
            SecurityRelease = $true
        }
        '15.2.986.42'  = @{
            Name            = 'Exchange Server 2019 CU13'
            ReleaseDate     = 'February 13, 2024'
            SecurityRelease = $true
        }
        '15.2.986.41'  = @{
            Name            = 'Exchange Server 2019 CU13'
            ReleaseDate     = 'January 9, 2024'
            SecurityRelease = $true
        }
        # ... more Exchange 2019 versions ...

        # Exchange Server 2016
        '15.1.2507.45' = @{
            Name            = 'Exchange Server 2016 CU23 Oct25SU'
            ReleaseDate     = '2025-10-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5039688'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
            Description     = 'Final Security Update before End of Support'
        }
        '15.1.2507.40' = @{
            Name            = 'Exchange Server 2016 CU23 Jul25SU'
            ReleaseDate     = '2025-07-09'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5038796'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.1.2507.27' = @{
            Name            = 'Exchange Server 2016 CU23'
            ReleaseDate     = 'February 13, 2024'
            SecurityRelease = $true
        }
        # ... more Exchange 2016 versions ...

        # Exchange Server 2013 (End of Support)
        '15.0.1497.48' = @{
            Name            = 'Exchange Server 2013 CU23 Apr23SU'
            ReleaseDate     = '2023-04-11'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5027262'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2023-04-11'
            Description     = 'Final Update - End of Support'
        }

        # Exchange Server 2010 (End of Support)
        '14.3.509.0'   = @{
            Name            = 'Exchange Server 2010 SP3 RU32'
            ReleaseDate     = '2020-02-11'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB4537677'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2020-10-13'
            Description     = 'Final Update - End of Support'
        }

        # Exchange Server 2007 (End of Support)
        '8.3.517.0'    = @{
            Name            = 'Exchange Server 2007 SP3 RU23'
            ReleaseDate     = '2017-03-21'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB4011086'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2017-04-11'
            Description     = 'Final Update - End of Support'
        }

        # Exchange Server 2003 (End of Support)
        '6.5.7654.4'   = @{
            Name            = 'Exchange Server 2003 SP2'
            ReleaseDate     = '2005-10-19'
            SecurityRelease = $true
            UpdateType      = 'Service Pack'
            KB              = 'KB822853'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2014-04-08'
            Description     = 'Final Update - End of Support'
        }
    }

    function Format-ExchangeVersion {
        param (
            [string]$Version
        )
        
        $majorVersion = $Version.Split('.')[0, 1] -join '.'
        $minorVersion = $Version.Split('.')[2, 3] -join '.'
        
        return @{
            MajorVersion = $majorVersion
            MinorVersion = $minorVersion
        }
    }

    function Get-ExchangeVersionDetails {
        try {
            $exchangeServer = Get-ExchangeServer
            $currentVersion = $exchangeServer.AdminDisplayVersion.ToString()
            $versionInfo = Format-ExchangeVersion -Version $currentVersion
            
            Write-Host "`nExchange Server Details" -ForegroundColor Cyan
            Write-Host '=====================' -ForegroundColor Cyan
            Write-Host "Server Name:`t`t$($exchangeServer.Name)"
            Write-Host "Server FQDN:`t`t$($exchangeServer.Fqdn)"
            Write-Host "Build Number:`t`t$currentVersion"
            Write-Host "Server Role:`t`t$($exchangeServer.ServerRole)"
            Write-Host "Edition:`t`t$($exchangeServer.Edition)"
            
            if ($ExchangeVersions[$versionInfo.MajorVersion] -and 
                $ExchangeVersions[$versionInfo.MajorVersion][$versionInfo.MinorVersion]) {
                $details = $ExchangeVersions[$versionInfo.MajorVersion][$versionInfo.MinorVersion]
                
                Write-Host "`nVersion Information" -ForegroundColor Green
                Write-Host '==================' -ForegroundColor Green
                Write-Host "Product Version:`t$($details.Name)"
                Write-Host "Release Date:`t`t$($details.ReleaseDate)"
                Write-Host "Security Release:`t$($details.SecurityRelease)"
                Write-Host "Support Status:`t$($details.SupportStatus)"
                Write-Host "End of Support:`t$($details.EndOfSupport)"
            }
            
            # Display all available Exchange versions
            Write-Host "`nExchange Version History" -ForegroundColor Yellow
            Write-Host '======================' -ForegroundColor Yellow
            
            foreach ($majorVersion in $ExchangeVersions.Keys | Sort-Object -Descending) {
                Write-Host "`n$majorVersion (Major Version)" -ForegroundColor Cyan
                foreach ($minorVersion in $ExchangeVersions[$majorVersion].Keys | Sort-Object -Descending) {
                    $details = $ExchangeVersions[$majorVersion][$minorVersion]
                    Write-Host "`t$($details.Name)"
                    Write-Host "`t`tRelease Date: $($details.ReleaseDate)"
                    Write-Host "`t`tSupport Status: $($details.SupportStatus)"
                }
            }

            # Support Lifecycle Summary
            Write-Host "`nSupport Lifecycle Summary" -ForegroundColor Magenta
            Write-Host '======================' -ForegroundColor Magenta
            Write-Host 'Exchange SE: Subscription Based - Always Current'
            Write-Host 'Exchange 2019: Mainstream Support until October 14, 2025'
            Write-Host 'Exchange 2016: Extended Support until October 14, 2025'
            Write-Host 'Exchange 2013: End of Support (April 11, 2023)'
            Write-Host 'Exchange 2010: End of Support (October 13, 2020)'
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