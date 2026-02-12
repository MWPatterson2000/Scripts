function Get-ExchangeReleaseVersion {
    # Create comprehensive version mapping
    $ExchangeVersions = @{
        # Exchange Server Subscription Edition (SE)
        '15.3.1750.15' = @{
            Name            = 'Exchange Server SE CU1 Jan26SU'
            ReleaseDate     = '2026-01-13'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5041234'
            SupportStatus   = 'Current'
            Description     = 'January 2026 Security Update'
        }
        '15.3.1750.13' = @{
            Name            = 'Exchange Server SE CU1 Oct25SU'
            ReleaseDate     = '2025-10-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5039689'
            SupportStatus   = 'Current'
        }
        '15.3.1750.12' = @{
            Name            = 'Exchange Server SE CU1 Jul25SU'
            ReleaseDate     = '2025-07-09'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5038797'
            SupportStatus   = 'Current'
        }
        '15.3.1750.11' = @{
            Name            = 'Exchange Server SE CU1 Apr25SU'
            ReleaseDate     = '2025-04-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5036695'
            SupportStatus   = 'Current'
        }
        '15.3.1750.8'  = @{
            Name            = 'Exchange Server SE CU1'
            ReleaseDate     = '2025-01-14'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5034265'
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
        '15.2.1258.34' = @{
            Name            = 'Exchange Server 2019 CU15 Jan26SU'
            ReleaseDate     = '2026-01-13'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5041233'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.2.1258.32' = @{
            Name            = 'Exchange Server 2019 CU15 Oct25SU'
            ReleaseDate     = '2025-10-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5039688'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
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
            ReleaseDate     = '2024-02-13'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5034791'
            SupportStatus   = 'Mainstream Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.2.1118.30' = @{
            Name            = 'Exchange Server 2019 CU14 Apr25SU'
            ReleaseDate     = '2025-04-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5037987'
            SupportStatus   = 'Out of Support'
        }
        '15.2.1118.26' = @{
            Name            = 'Exchange Server 2019 CU14'
            ReleaseDate     = '2023-10-10'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5030857'
            SupportStatus   = 'Out of Support'
        }
        '15.2.986.42'  = @{
            Name            = 'Exchange Server 2019 CU13 Apr25SU'
            ReleaseDate     = '2025-04-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5037986'
            SupportStatus   = 'Out of Support'
        }
        '15.2.986.41'  = @{
            Name            = 'Exchange Server 2019 CU13'
            ReleaseDate     = '2023-06-27'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5027699'
            SupportStatus   = 'Out of Support'
        }
        '15.2.858.15'  = @{
            Name            = 'Exchange Server 2019 CU12'
            ReleaseDate     = '2023-01-10'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5022017'
            SupportStatus   = 'Out of Support'
        }
        '15.2.792.3'   = @{
            Name            = 'Exchange Server 2019 CU11'
            ReleaseDate     = '2022-09-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5017453'
            SupportStatus   = 'Out of Support'
        }
        '15.2.721.2'   = @{
            Name            = 'Exchange Server 2019 CU10'
            ReleaseDate     = '2021-12-14'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5008617'
            SupportStatus   = 'Out of Support'
        }
        '15.2.659.4'   = @{
            Name            = 'Exchange Server 2019 CU9'
            ReleaseDate     = '2021-09-28'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5004897'
            SupportStatus   = 'Out of Support'
        }
        '15.2.595.3'   = @{
            Name            = 'Exchange Server 2019 CU8'
            ReleaseDate     = '2021-06-15'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5002901'
            SupportStatus   = 'Out of Support'
        }
        '15.2.529.5'   = @{
            Name            = 'Exchange Server 2019 CU7'
            ReleaseDate     = '2021-04-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5001779'
            SupportStatus   = 'Out of Support'
        }
        '15.2.464.5'   = @{
            Name            = 'Exchange Server 2019 CU6'
            ReleaseDate     = '2020-10-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4577352'
            SupportStatus   = 'Out of Support'
        }
        '15.2.397.3'   = @{
            Name            = 'Exchange Server 2019 CU5'
            ReleaseDate     = '2020-06-16'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4557831'
            SupportStatus   = 'Out of Support'
        }
        '15.2.330.5'   = @{
            Name            = 'Exchange Server 2019 CU4'
            ReleaseDate     = '2020-03-17'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4538931'
            SupportStatus   = 'Out of Support'
        }
        '15.2.221.12'  = @{
            Name            = 'Exchange Server 2019 CU3'
            ReleaseDate     = '2019-09-17'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4468319'
            SupportStatus   = 'Out of Support'
        }
        '15.2.196.0'   = @{
            Name            = 'Exchange Server 2019 CU2'
            ReleaseDate     = '2019-06-18'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4464537'
            SupportStatus   = 'Out of Support'
        }
        '15.2.159.3'   = @{
            Name            = 'Exchange Server 2019 CU1'
            ReleaseDate     = '2019-02-12'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4338228'
            SupportStatus   = 'Out of Support'
        }
        '15.2.66.40'   = @{
            Name            = 'Exchange Server 2019 RTM'
            ReleaseDate     = '2018-10-22'
            SecurityRelease = $false
            UpdateType      = 'RTM'
            KB              = 'N/A'
            SupportStatus   = 'Out of Support'
        }

        # Exchange Server 2016
        '15.1.2507.47' = @{
            Name            = 'Exchange Server 2016 CU23 Jan26SU'
            ReleaseDate     = '2026-01-13'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5041232'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.1.2507.45' = @{
            Name            = 'Exchange Server 2016 CU23 Oct25SU'
            ReleaseDate     = '2025-10-08'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5039687'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.1.2507.40' = @{
            Name            = 'Exchange Server 2016 CU23 Jul25SU'
            ReleaseDate     = '2025-07-09'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5038795'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.1.2507.27' = @{
            Name            = 'Exchange Server 2016 CU23'
            ReleaseDate     = '2024-02-13'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5034790'
            SupportStatus   = 'Extended Support'
            EndOfSupport    = '2025-10-14'
        }
        '15.1.2375.37' = @{
            Name            = 'Exchange Server 2016 CU22'
            ReleaseDate     = '2023-10-10'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5030856'
            SupportStatus   = 'Out of Support'
        }
        '15.1.2308.27' = @{
            Name            = 'Exchange Server 2016 CU21'
            ReleaseDate     = '2023-06-27'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5027698'
            SupportStatus   = 'Out of Support'
        }
        '15.1.2242.12' = @{
            Name            = 'Exchange Server 2016 CU20'
            ReleaseDate     = '2022-11-01'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5017452'
            SupportStatus   = 'Out of Support'
        }
        '15.1.2176.12' = @{
            Name            = 'Exchange Server 2016 CU19'
            ReleaseDate     = '2021-09-28'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5004896'
            SupportStatus   = 'Out of Support'
        }
        '15.1.2106.13' = @{
            Name            = 'Exchange Server 2016 CU18'
            ReleaseDate     = '2021-06-15'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5002900'
            SupportStatus   = 'Out of Support'
        }
        '15.1.2044.4'  = @{
            Name            = 'Exchange Server 2016 CU17'
            ReleaseDate     = '2021-04-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB5001778'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1979.3'  = @{
            Name            = 'Exchange Server 2016 CU16'
            ReleaseDate     = '2020-10-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4577354'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1913.5'  = @{
            Name            = 'Exchange Server 2016 CU15'
            ReleaseDate     = '2020-06-16'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4557832'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1847.3'  = @{
            Name            = 'Exchange Server 2016 CU14'
            ReleaseDate     = '2020-03-17'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4538932'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1779.2'  = @{
            Name            = 'Exchange Server 2016 CU13'
            ReleaseDate     = '2019-09-17'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4468319'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1713.5'  = @{
            Name            = 'Exchange Server 2016 CU12'
            ReleaseDate     = '2019-06-18'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4464538'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1647.2'  = @{
            Name            = 'Exchange Server 2016 CU11'
            ReleaseDate     = '2019-02-12'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4340731'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1591.10' = @{
            Name            = 'Exchange Server 2016 CU10'
            ReleaseDate     = '2018-10-09'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4471392'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1531.3'  = @{
            Name            = 'Exchange Server 2016 CU9'
            ReleaseDate     = '2018-06-19'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4340731'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1466.3'  = @{
            Name            = 'Exchange Server 2016 CU8'
            ReleaseDate     = '2018-03-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4058595'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1415.2'  = @{
            Name            = 'Exchange Server 2016 CU7'
            ReleaseDate     = '2017-12-12'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4038269'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1395.4'  = @{
            Name            = 'Exchange Server 2016 CU6'
            ReleaseDate     = '2017-09-19'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4012628'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1367.3'  = @{
            Name            = 'Exchange Server 2016 CU5'
            ReleaseDate     = '2017-06-27'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3996064'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1339.23' = @{
            Name            = 'Exchange Server 2016 CU4'
            ReleaseDate     = '2017-03-21'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4012628'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1261.35' = @{
            Name            = 'Exchange Server 2016 CU3'
            ReleaseDate     = '2016-12-13'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3798577'
            SupportStatus   = 'Out of Support'
        }
        '15.1.1176.8'  = @{
            Name            = 'Exchange Server 2016 CU2'
            ReleaseDate     = '2016-09-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3798577'
            SupportStatus   = 'Out of Support'
        }
        '15.1.845.34'  = @{
            Name            = 'Exchange Server 2016 CU1'
            ReleaseDate     = '2016-06-21'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3150695'
            SupportStatus   = 'Out of Support'
        }
        '15.1.396.30'  = @{
            Name            = 'Exchange Server 2016 RTM'
            ReleaseDate     = '2015-11-01'
            SecurityRelease = $false
            UpdateType      = 'RTM'
            KB              = 'N/A'
            SupportStatus   = 'Out of Support'
        }

        # Exchange Server 2013
        '15.0.1497.48' = @{
            Name            = 'Exchange Server 2013 CU23 Apr23SU'
            ReleaseDate     = '2023-04-11'
            SecurityRelease = $true
            UpdateType      = 'Security Update'
            KB              = 'KB5027262'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2023-04-11'
        }
        '15.0.1497.2'  = @{
            Name            = 'Exchange Server 2013 CU23'
            ReleaseDate     = '2019-02-12'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4340731'
            SupportStatus   = 'End of Support'
        }
        '15.0.1395.10' = @{
            Name            = 'Exchange Server 2013 CU22'
            ReleaseDate     = '2018-06-19'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB4076950'
            SupportStatus   = 'End of Support'
        }
        '15.0.1367.3'  = @{
            Name            = 'Exchange Server 2013 CU21'
            ReleaseDate     = '2017-06-27'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3996064'
            SupportStatus   = 'End of Support'
        }
        '15.0.1293.2'  = @{
            Name            = 'Exchange Server 2013 CU20'
            ReleaseDate     = '2017-03-21'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3996064'
            SupportStatus   = 'End of Support'
        }
        '15.0.1263.5'  = @{
            Name            = 'Exchange Server 2013 CU19'
            ReleaseDate     = '2016-12-13'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3798577'
            SupportStatus   = 'End of Support'
        }
        '15.0.1236.3'  = @{
            Name            = 'Exchange Server 2013 CU18'
            ReleaseDate     = '2016-09-20'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3798577'
            SupportStatus   = 'End of Support'
        }
        '15.0.1210.3'  = @{
            Name            = 'Exchange Server 2013 CU17'
            ReleaseDate     = '2016-06-21'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3150695'
            SupportStatus   = 'End of Support'
        }
        '15.0.1178.4'  = @{
            Name            = 'Exchange Server 2013 CU16'
            ReleaseDate     = '2016-03-15'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3114018'
            SupportStatus   = 'End of Support'
        }
        '15.0.1156.6'  = @{
            Name            = 'Exchange Server 2013 CU15'
            ReleaseDate     = '2015-12-08'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3098814'
            SupportStatus   = 'End of Support'
        }
        '15.0.1130.7'  = @{
            Name            = 'Exchange Server 2013 CU14'
            ReleaseDate     = '2015-09-15'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3077595'
            SupportStatus   = 'End of Support'
        }
        '15.0.1104.5'  = @{
            Name            = 'Exchange Server 2013 CU13'
            ReleaseDate     = '2015-06-16'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3051496'
            SupportStatus   = 'End of Support'
        }
        '15.0.1081.2'  = @{
            Name            = 'Exchange Server 2013 CU12'
            ReleaseDate     = '2015-03-17'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3041657'
            SupportStatus   = 'End of Support'
        }
        '15.0.1059.5'  = @{
            Name            = 'Exchange Server 2013 CU11'
            ReleaseDate     = '2014-12-09'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB3012332'
            SupportStatus   = 'End of Support'
        }
        '15.0.1044.25' = @{
            Name            = 'Exchange Server 2013 CU10'
            ReleaseDate     = '2014-09-16'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2936439'
            SupportStatus   = 'End of Support'
        }
        '15.0.1023.27' = @{
            Name            = 'Exchange Server 2013 CU9'
            ReleaseDate     = '2014-06-10'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2936439'
            SupportStatus   = 'End of Support'
        }
        '15.0.1010.12' = @{
            Name            = 'Exchange Server 2013 CU8'
            ReleaseDate     = '2014-04-14'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2919013'
            SupportStatus   = 'End of Support'
        }
        '15.0.995.29'  = @{
            Name            = 'Exchange Server 2013 CU7'
            ReleaseDate     = '2014-02-24'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2894536'
            SupportStatus   = 'End of Support'
        }
        '15.0.995.8'   = @{
            Name            = 'Exchange Server 2013 CU6'
            ReleaseDate     = '2013-12-09'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2863082'
            SupportStatus   = 'End of Support'
        }
        '15.0.913.22'  = @{
            Name            = 'Exchange Server 2013 CU5'
            ReleaseDate     = '2013-10-02'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2839017'
            SupportStatus   = 'End of Support'
        }
        '15.0.891.11'  = @{
            Name            = 'Exchange Server 2013 CU4'
            ReleaseDate     = '2013-08-13'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2832196'
            SupportStatus   = 'End of Support'
        }
        '15.0.847.32'  = @{
            Name            = 'Exchange Server 2013 CU3'
            ReleaseDate     = '2013-06-25'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2815801'
            SupportStatus   = 'End of Support'
        }
        '15.0.775.38'  = @{
            Name            = 'Exchange Server 2013 CU2'
            ReleaseDate     = '2013-04-02'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2791771'
            SupportStatus   = 'End of Support'
        }
        '15.0.712.24'  = @{
            Name            = 'Exchange Server 2013 CU1'
            ReleaseDate     = '2013-02-04'
            SecurityRelease = $false
            UpdateType      = 'Cumulative Update'
            KB              = 'KB2737216'
            SupportStatus   = 'End of Support'
        }
        '15.0.620.29'  = @{
            Name            = 'Exchange Server 2013 RTM'
            ReleaseDate     = '2012-12-03'
            SecurityRelease = $false
            UpdateType      = 'RTM'
            KB              = 'N/A'
            SupportStatus   = 'End of Support'
        }

        # Exchange Server 2010
        '14.3.509.0'   = @{
            Name            = 'Exchange Server 2010 SP3 RU32'
            ReleaseDate     = '2020-02-11'
            SecurityRelease = $true
            UpdateType      = 'Rollup Update'
            KB              = 'KB4537677'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2020-10-13'
        }
        '14.3.496.0'   = @{
            Name            = 'Exchange Server 2010 SP3 RU31'
            ReleaseDate     = '2019-04-09'
            SecurityRelease = $true
            UpdateType      = 'Rollup Update'
            KB              = 'KB4464537'
            SupportStatus   = 'End of Support'
        }
        '14.3.489.0'   = @{
            Name            = 'Exchange Server 2010 SP3 RU30'
            ReleaseDate     = '2018-10-09'
            SecurityRelease = $true
            UpdateType      = 'Rollup Update'
            KB              = 'KB4471392'
            SupportStatus   = 'End of Support'
        }
        '14.3.353.0'   = @{
            Name            = 'Exchange Server 2010 SP3'
            ReleaseDate     = '2012-04-10'
            SecurityRelease = $false
            UpdateType      = 'Service Pack'
            KB              = 'KB2753375'
            SupportStatus   = 'End of Support'
        }

        # Exchange Server 2007
        '8.3.517.0'    = @{
            Name            = 'Exchange Server 2007 SP3 RU23'
            ReleaseDate     = '2017-03-21'
            SecurityRelease = $true
            UpdateType      = 'Rollup Update'
            KB              = 'KB4011086'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2017-04-11'
        }
        '8.3.456.2'    = @{
            Name            = 'Exchange Server 2007 SP3'
            ReleaseDate     = '2009-12-08'
            SecurityRelease = $false
            UpdateType      = 'Service Pack'
            KB              = 'KB976934'
            SupportStatus   = 'End of Support'
        }

        # Exchange Server 2003
        '6.5.7654.4'   = @{
            Name            = 'Exchange Server 2003 SP2'
            ReleaseDate     = '2005-10-19'
            SecurityRelease = $true
            UpdateType      = 'Service Pack'
            KB              = 'KB822853'
            SupportStatus   = 'End of Support'
            EndOfSupport    = '2014-04-08'
        }
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