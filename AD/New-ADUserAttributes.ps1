<#
.Synopsis
   Creates custom attributes for users in Active Directory schema
.DESCRIPTION
   The New-ADUserAttributes cmdlet creates custom attributes for users in Active Directory schema using CSV file. The fields for Csv file are Name,Description,oMSyntax,AttributeSyntax,isSingleValued,Indexable. See the sample CSV file for more details: https://www.techtutsonline.com/scripts/adAttributes.csv
.EXAMPLE
   New-ADUserAttributes -CsvFile "Z:\adAttributes.csv"
   This script imports the specified Csv file and creates the custom AD attributes as defined in the CSV file. Download the sample CSV file: https://www.techtutsonline.com/scripts/adAttributes.csv
.NOTES
    Author : Surender Kumar
    Author URI : https://www.techtutsonline.com/staff/surender-kumar/
    Version : 1.0
    Sample CSV File : https://www.techtutsonline.com/scripts/adAttributes.csv
#>
function New-ADUserAttributes{
    [CmdletBinding()]
    Param
    (
        # Specify the path of Csv file
        [Parameter(Mandatory=$true,
                   Position=0)]
        [Alias('File','Csv')]
        [string]$CsvFile
    )

    # Function to generate the unique OIDs for custom attributes
    Function GenerateOID {
    $Prefix = "1.2.840.113556.1.8000.2554"
    $GUID = [System.Guid]::NewGuid().ToString()
    $GUIDPart = @()
    $GUIDPart += [UInt64]::Parse($GUID.SubString(0,4), "AllowHexSpecifier")
    $GUIDPart += [UInt64]::Parse($GUID.SubString(4,4), "AllowHexSpecifier")
    $GUIDPart += [UInt64]::Parse($GUID.SubString(9,4), "AllowHexSpecifier")
    $GUIDPart += [UInt64]::Parse($GUID.SubString(14,4), "AllowHexSpecifier")
    $GUIDPart += [UInt64]::Parse($GUID.SubString(19,4), "AllowHexSpecifier")
    $GUIDPart += [UInt64]::Parse($GUID.SubString(24,6), "AllowHexSpecifier")
    $GUIDPart += [UInt64]::Parse($GUID.SubString(30,6), "AllowHexSpecifier")
    $OID = [String]::Format("{0}.{1}.{2}.{3}.{4}.{5}.{6}.{7}", $Prefix, $GUIDPart[0], $GUIDPart[1], $GUIDPart[2], $GUIDPart[3], $GUIDPart[4], $GUIDPart[5], $GUIDPart[6])
    Return $OID
    }

    # Get AD schema
    $adSchema = (Get-ADRootDSE).schemaNamingContext
 
    # Get user schema
    $userSchema = Get-ADObject -SearchBase $adSchema -Filter "Name -eq 'User'"

    # Import CSV file
    $csvAttributes = Import-Csv $CsvFile
    if(!$csvAttributes){
        Write-Host "Please specify a valid CSV file. See the sample CSV file in help section..." -ForegroundColor Red
    } else {
        # Parse the CSV file
        ForEach ($Attribute in $csvAttributes)
        {
            # Define the hashtable for OtherAttributes parameter
            $adAttributes = @{
                attributeId = GenerateOID; # Unique OID automatically generated by GenerateOID function
                lDAPDisplayName = $Attribute.Name; # Name field in CSV should contain single word without spaces
                adminDescription = $Attribute.Description; # Description field in CSV should contain a short description
                oMSyntax = $Attribute.oMSyntax; # oMSyntax field in CSV should contain "64" for String (Unicode). Refer this link for other types: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/7cda533e-d7a4-4aec-a517-91d02ff4a1aa
                attributeSyntax =  $Attribute.AttributeSyntax; # attributeSyntax field in CSV should contain "2.5.5.12" for String (Unicode). Refer this link for other types: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/7cda533e-d7a4-4aec-a517-91d02ff4a1aa
                isSingleValued = if($Attribute.isSingleValued -like "*true*") {$true} else {$false}; # isSingleValued field in CSV can have (True or False) boolean value. Set this to "False" if you want your attribute to hold multiple values.
                #searchflags = if($Attribute.Indexable -like "yes") {1} else {0} # Indexable field in CSV can have (Yes or No) boolean value. Set this to "Yes" only if you would be querying this AD attribute a lot.
                searchflags = $Attribute.searchflags # Some customers may want to set the Confidentiality bit to hide data in Active Directory.  If the setting is not done correctly, unexpected results can occur.
                }

            try {
                # Create the custom attribute in AD schema
                New-ADObject -Name  $Attribute.Name -Type attributeSchema -Path $adSchema -OtherAttributes $adAttributes -ErrorAction Stop
 
                # Add the custom attribute to user class
                $userSchema | Set-ADObject -Add @{mayContain = $Attribute.Name} -ErrorAction Stop
                }

            catch {
                throw
                }
            }
        # Wait for custom attributes to propagate to other DCs. Adjust this time if needed
        Write-Host "Creating the requested custom attributes. Please wait..." -ForegroundColor Green
        Start-Sleep -Seconds 5

        # Restarting the AD services  
        $title = "You must restart the AD services for changes to take effect"
        $prompt = "Do you want to restart the services now?"
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $decision = $Host.UI.PromptForChoice($title, $prompt, $options, 1)
        if ($decision -eq 0) {
            Write-Host "Restarting the AD services..." -ForegroundColor Yellow -BackgroundColor Black
            Get-Service NTDS -DependentServices | Restart-Service -Force -Verbose
            Write-Host "The script was successful. You can now start using the new custom attributes..." -ForegroundColor Green 
        } else {
            Write-Host "You need to manually restart the AD services to start using new custom attribues..." -ForegroundColor Yellow
            }
   }
}

# Variable
$CsvFile = '.\Schema Import.csv'

# Call Function
#New-ADUserAttributes
New-ADUserAttributes -CsvFile $CsvFile

# SIG # Begin signature block
# MIIWtQYJKoZIhvcNAQcCoIIWpjCCFqICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUq9Tq2lkSbkhbS6PF0AkM48tt
# 67qgghEBMIIDAjCCAeqgAwIBAgIQRCmnZXezGZZIeH//dQYCGTANBgkqhkiG9w0B
# AQsFADAZMRcwFQYDVQQDDA5UZWNoVHV0c09ubGluZTAeFw0yMjAzMjEwOTQ1MjZa
# Fw0yNzAzMjEwOTU1MjZaMBkxFzAVBgNVBAMMDlRlY2hUdXRzT25saW5lMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqmEqjB5GD9mUcfU2c7K0fTPH9rX2
# S3YGFD/d675+1NPp61v8to1w1ppN8fU/EtYj94WAXxB0BiMcuB5vjJ4uXA7f9vXX
# rFhg0eSo7MRAzNiG1LKGkbLu4e45LprFEdy2pDCIT66lOTOVi+oYd7QIH7D7b6nA
# 4P/OuDb83PabZ6a9bioSV0HXAIaRVub9OLDz6LaJzHBMHRQr27OKhejVnW+2EWoK
# dQ3k24pxM1shGPi9GYdn+sACZ9fk0hOAmRjuDlyervSyPQPmDIXTbJTXKA6tZeop
# M3eqIRpcXsw6wM69/9CiK9jC/sdX3Fx9/P2CehhRpSMn7FPlKro9Ry75yQIDAQAB
# o0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0O
# BBYEFPfdHy1MJCtBSTWy/VZU7O7QtatyMA0GCSqGSIb3DQEBCwUAA4IBAQB6Tq0n
# RKBDHmdr7HM08BSmu+BT2+T1mjDMbuLtfpGRj8OA++1Us3g2aSnnO8lqeFc+ydpc
# 29CJcE5ebVEibkxOI214LXIYQcUpjGMHpBWYsjNh9p8fmuW9YOUBf7HeHhp5fSZB
# uxunAWBew4Ev7IYTwvSBdR8P5VDN3GmwQgxIL2xqfVk+xmdWybadNo3njRJxxoDc
# X/IkH5cZssK7Ft8F0dBUoeBrseZ05vtTLp+BEqg6Ee8kVnBuK7XeiR36oomQrpO/
# 9SKeqRUNYe6P8EA9UmphJARxPg5OGAtTJEimhfIOnysJciD+rK1RxYUqiLVTY17a
# zCdfDHc2nSLQxhLiMIIG7DCCBNSgAwIBAgIQMA9vrN1mmHR8qUY2p3gtuTANBgkq
# hkiG9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkx
# FDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5l
# dHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkwHhcNMTkwNTAyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjB9MQswCQYDVQQG
# EwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxm
# b3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28g
# UlNBIFRpbWUgU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
# AoICAQDIGwGv2Sx+iJl9AZg/IJC9nIAhVJO5z6A+U++zWsB21hoEpc5Hg7XrxMxJ
# NMvzRWW5+adkFiYJ+9UyUnkuyWPCE5u2hj8BBZJmbyGr1XEQeYf0RirNxFrJ29dd
# SU1yVg/cyeNTmDoqHvzOWEnTv/M5u7mkI0Ks0BXDf56iXNc48RaycNOjxN+zxXKs
# Lgp3/A2UUrf8H5VzJD0BKLwPDU+zkQGObp0ndVXRFzs0IXuXAZSvf4DP0REKV4TJ
# f1bgvUacgr6Unb+0ILBgfrhN9Q0/29DqhYyKVnHRLZRMyIw80xSinL0m/9NTIMdg
# aZtYClT0Bef9Maz5yIUXx7gpGaQpL0bj3duRX58/Nj4OMGcrRrc1r5a+2kxgzKi7
# nw0U1BjEMJh0giHPYla1IXMSHv2qyghYh3ekFesZVf/QOVQtJu5FGjpvzdeE8Nfw
# KMVPZIMC1Pvi3vG8Aij0bdonigbSlofe6GsO8Ft96XZpkyAcSpcsdxkrk5WYnJee
# 647BeFbGRCXfBhKaBi2fA179g6JTZ8qx+o2hZMmIklnLqEbAyfKm/31X2xJ2+opB
# JNQb/HKlFKLUrUMcpEmLQTkUAx4p+hulIq6lw02C0I3aa7fb9xhAV3PwcaP7Sn1F
# NsH3jYL6uckNU4B9+rY5WDLvbxhQiddPnTO9GrWdod6VQXqngwIDAQABo4IBWjCC
# AVYwHwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFBqh
# +GEZIA/DQXdFKI7RNV8GEgRVMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAG
# AQH/AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQ
# BgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRy
# dXN0UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBo
# MD8GCCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0
# UlNBQWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0
# cnVzdC5jb20wDQYJKoZIhvcNAQEMBQADggIBAG1UgaUzXRbhtVOBkXXfA3oyCy0l
# hBGysNsqfSoF9bw7J/RaoLlJWZApbGHLtVDb4n35nwDvQMOt0+LkVvlYQc/xQuUQ
# ff+wdB+PxlwJ+TNe6qAcJlhc87QRD9XVw+K81Vh4v0h24URnbY+wQxAPjeT5OGK/
# EwHFhaNMxcyyUzCVpNb0llYIuM1cfwGWvnJSajtCN3wWeDmTk5SbsdyybUFtZ83J
# b5A9f0VywRsj1sJVhGbks8VmBvbz1kteraMrQoohkv6ob1olcGKBc2NeoLvY3NdK
# 0z2vgwY4Eh0khy3k/ALWPncEvAQ2ted3y5wujSMYuaPCRx3wXdahc1cFaJqnyTdl
# Hb7qvNhCg0MFpYumCf/RoZSmTqo9CfUFbLfSZFrYKiLCS53xOV5M3kg9mzSWmglf
# jv33sVKRzj+J9hyhtal1H3G/W0NdZT1QgW6r8NDT/LKzH7aZlib0PHmLXGTMze4n
# muWgwAxyh8FuTVrTHurwROYybxzrF06Uw3hlIDsPQaof6aFBnf6xuKBlKjTg3qj5
# PObBMLvAoGMs/FwWAKjQxH/qEZ0eBsambTJdtDgJK0kHqv3sMNrxpy/Pt/360KOE
# 2See+wFmd7lWEOEgbsausfm2usg1XTN2jvF8IAwqd661ogKGuinutFoAsYyr4/kK
# yVRd1LlqdJ69SK6YMIIHBzCCBO+gAwIBAgIRAIx3oACP9NGwxj2fOkiDjWswDQYJ
# KoZIhvcNAQEMBQAwfTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFu
# Y2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1p
# dGVkMSUwIwYDVQQDExxTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIENBMB4XDTIw
# MTAyMzAwMDAwMFoXDTMyMDEyMjIzNTk1OVowgYQxCzAJBgNVBAYTAkdCMRswGQYD
# VQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDEsMCoGA1UEAwwjU2VjdGlnbyBSU0EgVGltZSBT
# dGFtcGluZyBTaWduZXIgIzIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQCRh0ssi8HxHqCe0wfGAcpSsL55eV0JZgYtLzV9u8D7J9pCalkbJUzq70DWmn4y
# yGqBfbRcPlYQgTU6IjaM+/ggKYesdNAbYrw/ZIcCX+/FgO8GHNxeTpOHuJreTAdO
# hcxwxQ177MPZ45fpyxnbVkVs7ksgbMk+bP3wm/Eo+JGZqvxawZqCIDq37+fWuCVJ
# wjkbh4E5y8O3Os2fUAQfGpmkgAJNHQWoVdNtUoCD5m5IpV/BiVhgiu/xrM2HYxiO
# dMuEh0FpY4G89h+qfNfBQc6tq3aLIIDULZUHjcf1CxcemuXWmWlRx06mnSlv53mT
# DTJjU67MximKIMFgxvICLMT5yCLf+SeCoYNRwrzJghohhLKXvNSvRByWgiKVKoVU
# rvH9Pkl0dPyOrj+lcvTDWgGqUKWLdpUbZuvv2t+ULtka60wnfUwF9/gjXcRXyCYF
# evyBI19UCTgqYtWqyt/tz1OrH/ZEnNWZWcVWZFv3jlIPZvyYP0QGE2Ru6eEVYFCl
# sezPuOjJC77FhPfdCp3avClsPVbtv3hntlvIXhQcua+ELXei9zmVN29OfxzGPATW
# McV+7z3oUX5xrSR0Gyzc+Xyq78J2SWhi1Yv1A9++fY4PNnVGW5N2xIPugr4srjcS
# 8bxWw+StQ8O3ZpZelDL6oPariVD6zqDzCIEa0USnzPe4MQIDAQABo4IBeDCCAXQw
# HwYDVR0jBBgwFoAUGqH4YRkgD8NBd0UojtE1XwYSBFUwHQYDVR0OBBYEFGl1N3u7
# nTVCTr9X05rbnwHRrt7QMA4GA1UdDwEB/wQEAwIGwDAMBgNVHRMBAf8EAjAAMBYG
# A1UdJQEB/wQMMAoGCCsGAQUFBwMIMEAGA1UdIAQ5MDcwNQYMKwYBBAGyMQECAQMI
# MCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20vQ1BTMEQGA1UdHwQ9
# MDswOaA3oDWGM2h0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1JTQVRpbWVT
# dGFtcGluZ0NBLmNybDB0BggrBgEFBQcBAQRoMGYwPwYIKwYBBQUHMAKGM2h0dHA6
# Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNydDAj
# BggrBgEFBQcwAYYXaHR0cDovL29jc3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEM
# BQADggIBAEoDeJBCM+x7GoMJNjOYVbudQAYwa0Vq8ZQOGVD/WyVeO+E5xFu66ZWQ
# Nze93/tk7OWCt5XMV1VwS070qIfdIoWmV7u4ISfUoCoxlIoHIZ6Kvaca9QIVy0RQ
# mYzsProDd6aCApDCLpOpviE0dWO54C0PzwE3y42i+rhamq6hep4TkxlVjwmQLt/q
# iBcW62nW4SW9RQiXgNdUIChPynuzs6XSALBgNGXE48XDpeS6hap6adt1pD55aJo2
# i0OuNtRhcjwOhWINoF5w22QvAcfBoccklKOyPG6yXqLQ+qjRuCUcFubA1X9oGsRl
# KTUqLYi86q501oLnwIi44U948FzKwEBcwp/VMhws2jysNvcGUpqjQDAXsCkWmcmq
# t4hJ9+gLJTO1P22vn18KVt8SscPuzpF36CAT6Vwkx+pEC0rmE4QcTesNtbiGoDCn
# i6GftCzMwBYjyZHlQgNLgM7kTeYqAT7AXoWgJKEXQNXb2+eYEKTx6hkbgFT6R4no
# mIGpdcAO39BolHmhoJ6OtrdCZsvZ2WsvTdjePjIeIOTsnE1CjZ3HM5mCN0TUJikm
# QI54L7nu+i/x8Y/+ULh43RSW3hwOcLAqhWqxbGjpKuQQK24h/dN8nTfkKgbWw/HX
# aONPB3mBCBP+smRe6bE85tB4I7IJLOImYr87qZdRzMdEMoGyr8/fMYIFHjCCBRoC
# AQEwLTAZMRcwFQYDVQQDDA5UZWNoVHV0c09ubGluZQIQRCmnZXezGZZIeH//dQYC
# GTAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAjBgkqhkiG9w0BCQQxFgQUltQ0DZDWmha0oVxNg9iqE5kR1+EwDQYJKoZIhvcN
# AQEBBQAEggEAAuqhzOADrazdn7f0FY58KvLuohwBBnCKMPIii56yltZs7JuGIYIB
# g4e+aN53HCTasWpJ2xRlcx+YTnMzfxJT5hGBX8I8bsIF0r4myHCXbsx58NawL7qM
# CpQfdDJGdGo6lNk6wtBxrDxm6WUVp7vAlUp0Vz3tlumm1NvKeYPLcyNSRePlLRXl
# gzCb1T+VMxnhBX7YlVsSQteqcjr23vMZulDdUt6APVGpmBDrn/zzEdWeZNIG6cnO
# 231UaAKqbNmJuiFsnDj+izSH1uk4j4nX6r+hiu//OGC/qE6gl8kGP2x7IeiazsAp
# 7s+yuq39ZPijQaIAEJUTL7YUcPt2NJZGHaGCA0wwggNIBgkqhkiG9w0BCQYxggM5
# MIIDNQIBATCBkjB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5j
# aGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0
# ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0ECEQCMd6AA
# j/TRsMY9nzpIg41rMA0GCWCGSAFlAwQCAgUAoHkwGAYJKoZIhvcNAQkDMQsGCSqG
# SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwMzI1MTEwMDM2WjA/BgkqhkiG9w0B
# CQQxMgQwdPJ869UclnNstw4yuBXSBqUtA/Bi0gcZjLVjsExivLpOoNXMsXrAayqK
# FNM3oml4MA0GCSqGSIb3DQEBAQUABIICAIdwNY+kQSJPcd9YsIet4bEIhlbJpSE+
# nixaenCtlWEVQeUyE+3FD8SPE45CXEWKT4IOe1WkJXDC9msYVXlBCQPiJb+ZRUB8
# VKmplEZmuSjmiOuqszilbcCn63R0QJ4WfL9rUcb65JyxJRBMThHVwmjdj9+QkBLy
# 0BOV/7Yq2nOJ6eMVf1eYQqKIaRpSFu8XLgVvAA16w2WERkEHvcHoOELQnzp5+Aya
# /89dN+82nb5/FZY7aFnzVpSwwkQtCtYUEVRvW6AjunUne2KlnPb73hieyDq8BVM4
# /84blXfk0XzIgEeNCYuaGIP602prj/3iSMsksOA6dl9nnf+oZ+zQT6k9jslf8U4y
# qPDBrwc0AoOo8ROvPqa7quozsQeAqaPPDU1GRCnDnLKgU+D22vN8XK7A4bcmICWF
# zpRot8E4tDI1vxv7W3KnDVww6tDCqvfGi8GXYVq6E0f18Zwzsn5zhAOXHa8rVMKx
# +Uy1+yHp0Cn4hYmdOIfKe3RIoddiVPnrWas6aGVVev+oyawgd3Yf3mcCMyUsCGnf
# BxHi1R79bwTfqNEtiGmJ9uYIRWE9cmNGONhwtZitetCTwYA/p4YtM2J6W9A863dg
# 3bCu2f6Vv1qVSGj3FuNKQnwBqTXuuZQOkr/PN6Z7fJKvLgrqo1Q6gl2HvY9JeCPA
# 9f2eZ4gkEnuk
# SIG # End signature block