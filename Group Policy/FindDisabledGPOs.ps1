# =============================================================================
# 
# NAME:FindDisabledGPOs.ps1
# 
# AUTHOR: Ed Wilson , microsoft
# DATE  : 12/10/2007
# 
# COMMENT: 
# Uses Params to allow modification of script at runtime
# Uses funHelp function to display help
# Uses funLine function to underline output
# 
#
# =============================================================================

param(
      $domain = $env:userDNSdomain,
      [switch]$query,
      [switch]$help,
      [switch]$examples,
      [switch]$min,
      [switch]$full
      ) #end param

# Begin Functions

function funHelp()
{
 $descriptionText= `
@"
 NAME: FindDisabledGPOs.ps1
 DESCRIPTION:
 Finds disabled GPOs in a local or remote
 domain. 

 PARAMETERS: 
 -domain Domain to query for unlinked GPOs
 -query Executes the query
 -help prints help description and parameters file
 -examples prints only help examples of syntax
 -full prints complete help information
 -min prints minimal help. Modifies -help

"@ #end descriptionText

$examplesText= `
@"

 SYNTAX:
 FindDisabledGPOs.ps1 

 Displays an error missing parameter, and calls help

 FindDisabledGPOs.ps1  -query

 Displays disabled GPOs from the default domain 

 FindDisabledGPOs.ps1 -domain nwtraders.com -query
 
 Displays disabled GPOs from the nwtraders.com domain

 FindDisabledGPOs.ps1 -help

 Prints the help topic for the script

 FindDisabledGPOs.ps1 -help -full

 Prints full help topic for the script

 FindDisabledGPOs.ps1 -help -examples

 Prints only the examples for the script

 FindDisabledGPOs.ps1 -examples

 Prints only the examples for the script
"@ #end examplesText

$remarks = `
"
REMARKS
     For more information, type: $($MyInvocation.ScriptName) -help -full
" #end remarks

  if($examples) { $examplesText ; $remarks ; exit }
  if($full)     { $descriptionText; $examplesText ; exit } 
  if($min)      { $descriptionText ; exit }
  $descriptionText; $remarks 
  exit
} #end funHelp function

function funline (
                  $strIN,
                  $char = "=",
                  $sColor = "Yellow",
                  $uColor = "darkYellow",
                  [switch]$help
                 )
{
 if($help)
  {
    $local:helpText = `
@"
     Funline accepts inputs: -strIN for input string and -char for seperator
     -sColor for the string color, and -uColor for the underline color. Only 
     the -strIn is required. The others have the following default values:
     -char: =, -sColor: Yellow, -uColor: darkYellow
     Example:
     funline -strIN "Hello world"
     funline -strIn "Morgen welt" -char "-" -sColor "blue" -uColor "yellow"
     funline -help
"@
   $local:helpText
   break
  } #end funline help
  
 $strLine= $char * $strIn.length
 Write-Host -ForegroundColor $sColor $strIN 
 Write-Host -ForegroundColor $uColor $strLine
} #end funLine function

Function FunDisplayDisabled ()
{
 $gpm = new-object -comobject GPMgmt.gpm
 $constants = $gpm.getConstants()
 $gpmDomain = $gpm.getDomain($domain,$null, $constants.UseAnyDC)
 $gpmSearchCriteria = $gpm.CreateSearchCriteria()
 $gpoList = $gpmDomain.SearchGPOs($gpmSearchCriteria)


 funline("Completely Disabled GPOs")
 foreach($objGPO in $gpoList)
  {
   if(!$objGPO.isUserEnabled() -and !$objGPO.isCOmputerENabled())
     { "$($objGPO.ID) `t $($objGPO.DisplayName)" }
 
  } #end foreach

 Funline("User side disabled GPOs")
 foreach($objGPO in $gpoList)
  {
   if(!$objGPO.isUserEnabled())
     { "$($objGPO.ID) `t $($objGPO.DisplayName)" }
 
  } #end foreach

 Funline("Computer side disabled GPOs")
 foreach($objGPO in $gpoList)
  {
   if(!$objGPO.isCOmputerENabled())
     { "$($objGPO.ID) `t $($objGPO.DisplayName)" }
 
  } #end foreach
  exit
} #end funDisplayDisabled

# Entry Point

if($help)      { funhelp }
if($examples)  { funhelp }
if($full)      { funhelp }
if($query)     { FunDisplayDisabled }
if(!$query)    { "Missing query." ; funhelp }

# SIG # Begin signature block
# MIIkCgYJKoZIhvcNAQcCoIIj+zCCI/cCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQnbkOzJYIj9ZqAdkXxfTAUdu
# hcKggh7hMIIEEjCCAvqgAwIBAgIPAMEAizw8iBHRPvZj7N9AMA0GCSqGSIb3DQEB
# BAUAMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQgQ29y
# cC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWlj
# cm9zb2Z0IFJvb3QgQXV0aG9yaXR5MB4XDTk3MDExMDA3MDAwMFoXDTIwMTIzMTA3
# MDAwMFowcDErMCkGA1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jvc29mdCBD
# b3JwLjEeMBwGA1UECxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhN
# aWNyb3NvZnQgUm9vdCBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCpAr3BcOY78k4bKJ+XeF4w6qKpjSVf+P6VTKO3/p2iID58UaKboo9g
# MmvRQmR57qx2yVTa8uuchhyPn4Rms8VremIj1h083g8BkuiWxL8tZpqaaCaZ0Dos
# vwy1WCbBRucKPjiWLKkoOajsSYNC44QPu5psVWGsgnyhYC13TOmZtGQ7mlAcMQgk
# FJ+p55ErGOY9mGMUYFgFZZ8dN1KH96fvlALGG9O/VUWziYC/OuxUlE6u/ad6bXRO
# rxjMlgkoIQBXkGBpN7tLEgc8Vv9b+6RmCgim0oFWV++2O14WgXcE2va+roCV/rDN
# f9anGnJcPMq88AijIjCzBoXJsyB3E4XfAgMBAAGjgagwgaUwgaIGA1UdAQSBmjCB
# l4AQW9Bw72lyniNRfhSyTY7/y6FyMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykg
# MTk5NyBNaWNyb3NvZnQgQ29ycC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFJvb3QgQXV0aG9yaXR5gg8AwQCLPDyI
# EdE+9mPs30AwDQYJKoZIhvcNAQEEBQADggEBAJXoC8CN85cYNe24ASTYdxHzXGAy
# n54Lyz4FkYiPyTrmIfLwV5MstaBHyGLv/NfMOztaqTZUaf4kbT/JzKreBXzdMY09
# nxBwarv+Ek8YacD80EPjEVogT+pie6+qGcgrNyUtvmWhEoolD2Oj91Qc+SHJ1hXz
# UqxuQzIH/YIX+OVnbA1R9r3xUse958Qw/CAxCYgdlSkaTdUdAqXxgOADtFv0sd3I
# V+5lScdSVLa0AygS/5DW8AiPfriXxas3LOR65Kh343agANBqP8HSNorgQRKoNWob
# ats14dQcBOSoRQTIWjM4bk0cDWK3CqKM09VUP0bNHFWmcNsSOoeTdZ+n0qAwggQS
# MIIC+qADAgECAg8AwQCLPDyIEdE+9mPs30AwDQYJKoZIhvcNAQEEBQAwcDErMCkG
# A1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jvc29mdCBDb3JwLjEeMBwGA1UE
# CxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgUm9v
# dCBBdXRob3JpdHkwHhcNOTcwMTEwMDcwMDAwWhcNMjAxMjMxMDcwMDAwWjBwMSsw
# KQYDVQQLEyJDb3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYD
# VQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBS
# b290IEF1dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkC
# vcFw5jvyThson5d4XjDqoqmNJV/4/pVMo7f+naIgPnxRopuij2Aya9FCZHnurHbJ
# VNry65yGHI+fhGazxWt6YiPWHTzeDwGS6JbEvy1mmppoJpnQOiy/DLVYJsFG5wo+
# OJYsqSg5qOxJg0LjhA+7mmxVYayCfKFgLXdM6Zm0ZDuaUBwxCCQUn6nnkSsY5j2Y
# YxRgWAVlnx03Uof3p++UAsYb079VRbOJgL867FSUTq79p3ptdE6vGMyWCSghAFeQ
# YGk3u0sSBzxW/1v7pGYKCKbSgVZX77Y7XhaBdwTa9r6ugJX+sM1/1qcaclw8yrzw
# CKMiMLMGhcmzIHcThd8CAwEAAaOBqDCBpTCBogYDVR0BBIGaMIGXgBBb0HDvaXKe
# I1F+FLJNjv/LoXIwcDErMCkGA1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jv
# c29mdCBDb3JwLjEeMBwGA1UECxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYD
# VQQDExhNaWNyb3NvZnQgUm9vdCBBdXRob3JpdHmCDwDBAIs8PIgR0T72Y+zfQDAN
# BgkqhkiG9w0BAQQFAAOCAQEAlegLwI3zlxg17bgBJNh3EfNcYDKfngvLPgWRiI/J
# OuYh8vBXkyy1oEfIYu/818w7O1qpNlRp/iRtP8nMqt4FfN0xjT2fEHBqu/4STxhp
# wPzQQ+MRWiBP6mJ7r6oZyCs3JS2+ZaESiiUPY6P3VBz5IcnWFfNSrG5DMgf9ghf4
# 5WdsDVH2vfFSx73nxDD8IDEJiB2VKRpN1R0CpfGA4AO0W/Sx3chX7mVJx1JUtrQD
# KBL/kNbwCI9+uJfFqzcs5HrkqHfjdqAA0Go/wdI2iuBBEqg1ahtq2zXh1BwE5KhF
# BMhaMzhuTRwNYrcKoozT1VQ/Rs0cVaZw2xI6h5N1n6fSoDCCBGAwggNMoAMCAQIC
# Ci6rEdxQ/1ydy8AwCQYFKw4DAh0FADBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMp
# IDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eTAeFw0wNzA4
# MjIyMjMxMDJaFw0xMjA4MjUwNzAwMDBaMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcg
# UENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt3l91l2zRTmoNKwx
# 2vklNUl3wPsfnsdFce/RRujUjMNrTFJi9JkCw03YSWwvJD5lv84jtwtIt3913UW9
# qo8OUMUlK/Kg5w0jH9FBJPpimc8ZRaWTSh+ZzbMvIsNKLXxv2RUeO4w5EDndvSn0
# ZjstATL//idIprVsAYec+7qyY3+C+VyggYSFjrDyuJSjzzimUIUXJ4dO3TD2AD30
# xvk9gb6G7Ww5py409rQurwp9YpF4ZpyYcw2Gr/LE8yC5TxKNY8ss2TJFGe67SpY7
# UFMYzmZReaqth8hWPp+CUIhuBbE1wXskvVJmPZlOzCt+M26ERwbRntBKhgJuhgCk
# wIffUwIDAQABo4H6MIH3MBMGA1UdJQQMMAoGCCsGAQUFBwMDMIGiBgNVHQEEgZow
# gZeAEFvQcO9pcp4jUX4Usk2O/8uhcjBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMp
# IDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eYIPAMEAizw8
# iBHRPvZj7N9AMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMwdznYAcFuv8drE
# TppRRC6jRGPwMAsGA1UdDwQEAwIBhjAJBgUrDgMCHQUAA4IBAQB7q65+SibyzrxO
# dKJYJ3QqdbOG/atMlHgATenK6xjcacUOonzzAkPGyofM+FPMwp+9Vm/wY0SpRADu
# lsia1Ry4C58ZDZTX2h6tKX3v7aZzrI/eOY49mGq8OG3SiK8j/d/p1mkJkYi9/uEA
# uzTz93z5EBIuBesplpNCayhxtziP4AcNyV1ozb2AQWtmqLu3u440yvIDEHx69dLg
# Qt97/uHhrP7239UNs3DWkuNPtjiifC3UPds0C2I3Ap+BaiOJ9lxjj7BauznXYIxV
# hBoz9TuYoIIMol+Lsyy3oaXLq9ogtr8wGYUgFA0qvFL0QeBeMOOSKGmHwXDi86er
# zoBCcnYOMIIEajCCA1KgAwIBAgIKYQ94TQAAAAAAAzANBgkqhkiG9w0BAQUFADB5
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpN
# aWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQTAeFw0wNzA4MjMwMDIzMTNaFw0wOTAy
# MjMwMDMzMTNaMHQxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAKLbCo3PwsFJm82qOjStI1lr22y+ISK3lMjqrr/G1SbC
# MhGLvNpdLPs2Vh4VK66PDd0Uo24oTH8WP0GsjUCxRogN2YGUrZcG0FdEdlzq8fwO
# 4n90ozPLdOXv42GhfgO3Rf/VPhLVsMpeDdB78rcTDfxgaiiFdYy3rbyF6Be0kL71
# FrZiXe0R3zruIVuLr4Bzw0XjlYl3YJvnrXfBN40zFC8T22LJrhqpT5hnrdQgOTBx
# 4I1nRuLGHPQNUHRBL+gFJGoha0mwksSyOcdCpW1cGEqrj9eOgz54CkfYpLKEI8Pi
# 8ntmsUp0vSZBS5xhFGBOMMiC89ALcHzuVU130ghVdoECAwEAAaOB+DCB9TAOBgNV
# HQ8BAf8EBAMCBsAwHQYDVR0OBBYEFPMhQI58UfhUS5jlF9dqgzQFLiboMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMB8GA1UdIwQYMBaAFMwdznYAcFuv8drETppRRC6jRGPw
# MEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kv
# Y3JsL3Byb2R1Y3RzL0NTUENBLmNybDBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUH
# MAKGLGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvQ1NQQ0EuY3J0
# MA0GCSqGSIb3DQEBBQUAA4IBAQBAV29TZ54ggzQBDuYXSzyt69iBf+4NeXR3T5dH
# GPMAFWl+22KQov1noZzkKCn6VdeZ/lC/XgmzuabtgvOYHm9Z+vXx4QzTiwg+Fhcg
# 0cC1RUcIJmBXCUuU8AjMuk1u8OJIEig1iyFy31+2r2kSJJTu6TQJ235ub5IKUsoq
# TEmqMiyG6KHMXSa8vDzgW7KDC7o1HE+ERUf/u5ShWQeplt14vVd/padOzPKtnJpB
# 4stcJD7cfzRHTvbPyHud67bJnGMUU6+tmu/Xv8+goauVynorhyzAx9n8bAPavzit
# 8dFcGRcPwPfKgKYQCBrdkCPnsKFMPuqwESZ4DsEsuaRrx488MIIEnTCCA4WgAwIB
# AgIKYUdSugAAAAAABDANBgkqhkiG9w0BAQUFADB5MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1w
# aW5nIFBDQTAeFw0wNjA5MTYwMTUzMDBaFw0xMTA5MTYwMjAzMDBaMIGmMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMScwJQYDVQQLEx5uQ2lwaGVy
# IERTRSBFU046RDhBOS1DRkNDLTU3OUMxJzAlBgNVBAMTHk1pY3Jvc29mdCBUaW1l
# c3RhbXBpbmcgU2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AJtt3IZR6DI7NzqWJbLPb+5htUHSGDtanXhnuvgf2QhVkoh+40FT+uwoVP612v5w
# O5UnSH5DoDIvJoFK8gJ2d8jJqfiiIVh+Db0B2iTG/kQRBTU6AajqVAozLIfSfkGz
# 6AnZsL7jmSWmvCXt19OO2/S3bRtJC+bTw4du7kbJf/Nt6+eDHqhTRj/KJH7mfMks
# +3kUKEXATzZrUxqnhrPn/OHBn1EJ27ylu/7Khwn2tzIZvuFKUby8fKwslWqXc+py
# V6Gci4bYm71L/CczwW0yrOBoGNhuOi4iQ9H5j+3xAAENZMDJo90P8cjpVMoR/9x4
# KT4drFjA29+q3K5lG9OdvGcCAwEAAaOB+DCB9TAdBgNVHQ4EFgQUTxiJitLKAHjG
# 7FkND/18xMEigN4wHwYDVR0jBBgwFoAUb+hOP5e5NKtLho+8nOqsO0FDxtAwRAYD
# VR0fBD0wOzA5oDegNYYzaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvdHNwY2EuY3JsMEgGCCsGAQUFBwEBBDwwOjA4BggrBgEFBQcwAoYs
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy90c3BjYS5jcnQwEwYD
# VR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgbAMA0GCSqGSIb3DQEBBQUA
# A4IBAQA3Jx71jEDg9mUmPmTEkLw+41eF3UMNQIRnvoeoKtrctDYgmI4zfC5f4FB7
# YTHzGhPehL3qaRxYfLMbk+EIJ4FFttRwyhS3X7pX6dRe0DtDqrc/ttphi3HP1H3V
# e26/tMpaMJHf2goOozWfJWFOwDJ0K3oGlHIArBidS+WeK8U6VKykYNin95t/2alt
# 7URrutzgEvrwrYcMlWMKMh6JTszMfqc3pf5f2Gf6RkvRbR2nfdK+Av/zboLzh3TE
# aeW5cMxLZaMHNalEnoR9OW7+FAW9GlAhtT6f83ccj8KanVfhaX1p6IPPAm8qIrs3
# Mzpy+tYwHZGt9lAa6xPeOsW3XM2zMIIEnTCCA4WgAwIBAgIKYUl87QAAAAAABTAN
# BgkqhkiG9w0BAQUFADB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1waW5nIFBDQTAeFw0wNjA5
# MTYwMTU1MjJaFw0xMTA5MTYwMjA1MjJaMIGmMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBFU046MTBEOC01
# ODQ3LUNCRjgxJzAlBgNVBAMTHk1pY3Jvc29mdCBUaW1lc3RhbXBpbmcgU2Vydmlj
# ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOq6BWPI2XmuhEQ+pbPE
# 7UyeJN85dh4J1jJKWHjSK9mlB5Dv5z37vSZ8o/vlfX4yz9k9izk38vjYOzQW1JKC
# +zTsaIVyGo/guEzguIXzMwoCwaJ2czVMXfG34Up9HbiUeNv/HoUVQkZxzn8nVxLR
# g087z/re9ovtPwDj1d5h+ReNS6SBPPVpQOrhib8HT7p0e+kM5Ufqq2zx1WeBCPgW
# yn0Tu3PiCUz6YvvtoDmaOv7rEchhHmJY2ApUg9U7S0viVb0vYBqOkgVD2l3rggoj
# lwmgBTFli5NOHkEhopKQ/UVERW81sUU3rWmpZfk0Q7EXwjs54RCM8hqH41RQHzud
# Ma0CAwEAAaOB+DCB9TAdBgNVHQ4EFgQUfnLwLj9WKeAl92i4AfxL4X7P4z4wHwYD
# VR0jBBgwFoAUb+hOP5e5NKtLho+8nOqsO0FDxtAwRAYDVR0fBD0wOzA5oDegNYYz
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvdHNwY2Eu
# Y3JsMEgGCCsGAQUFBwEBBDwwOjA4BggrBgEFBQcwAoYsaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraS9jZXJ0cy90c3BjYS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgbAMA0GCSqGSIb3DQEBBQUAA4IBAQBpeoIJDBbR3s9G
# iS6/0TR6gX8nKEEq89Mhkg6XrV9TXin57cFUSqh99xPQCxT5TfKGFQBu44MdKEWn
# LDky3W+aN1ruI1KPVAONP6ecZDj2NsgUQ7Y6PpjJDcNxgSjzZqcx4lxdj/lSUuFc
# 65OQnWkJTInR0XZMNA1q4XxEpytbg1R/RSQZJcSKRsUl4xmAaSkU9hfG8CIsgUZe
# K/T5psZ3PiNv+aZkhY6iYg2pLR6o5ZA+f/+wjvyX7PH9BK/NSc5adKz68xMfGznO
# o7TWvPS07sit8lYe+zzxyNYqRLy/nD99ZhjNsiBjCspAPWUyGXyyuD3BJkhOIhmZ
# bowwwfGRMIIEnTCCA4WgAwIBAgIQaguZT8AAJasR20UfWHpnojANBgkqhkiG9w0B
# AQUFADBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENv
# cnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1p
# Y3Jvc29mdCBSb290IEF1dGhvcml0eTAeFw0wNjA5MTYwMTA0NDdaFw0xOTA5MTUw
# NzAwMDBaMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBUaW1lc3RhbXBpbmcgUENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEA3Ddu+6/IQkpxGMjOSD5TwPqrFLosMrsST1LIg+0+
# M9lJMZIotpFk4B9QhLrCS9F/Bfjvdb6Lx6jVrmlwZngnZui2t++Fuc3uqv0SpAtZ
# Iikvz0DZVgQbdrVtZG1KVNvd8d6/n4PHgN9/TAI3lPXAnghWHmhHzdnAdlwvfbYl
# BLRWW2ocY/+AfDzu1QQlTTl3dAddwlzYhjcsdckO6h45CXx2/p1sbnrg7D6Pl55x
# Dl8qTxhiYDKe0oNOKyJcaEWL3i+EEFCy+bUajWzuJZsT+MsQ14UO9IJ2czbGlXqi
# zGAG7AWwhjO3+JRbhEGEWIWUbrAfLEjMb5xD4GrofyaOawIDAQABo4IBKDCCASQw
# EwYDVR0lBAwwCgYIKwYBBQUHAwgwgaIGA1UdAQSBmjCBl4AQW9Bw72lyniNRfhSy
# TY7/y6FyMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQg
# Q29ycC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMY
# TWljcm9zb2Z0IFJvb3QgQXV0aG9yaXR5gg8AwQCLPDyIEdE+9mPs30AwEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFG/oTj+XuTSrS4aPvJzqrDtBQ8bQMBkGCSsG
# AQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTAD
# AQH/MA0GCSqGSIb3DQEBBQUAA4IBAQCUTRExwnxQuxGOoWEHAQ6McEWN73NUvT8J
# BS3/uFFThRztOZG3o1YL3oy2OxvR+6ynybexUSEbbwhpfmsDoiJG7Wy0bXwiuEbT
# hPOND74HijbB637pcF1Fn5LSzM7djsDhvyrNfOzJrjLVh7nLY8Q20Rghv3beO5qz
# G3OeIYjYtLQSVIz0nMJlSpooJpxgig87xxNleEi7z62DOk+wYljeMOnpOR3jifLa
# OYH5EyGMZIBjBgSW8poCQy97Roi6/wLZZflK3toDdJOzBW4MzJ3cKGF8SPEXnBEh
# OAIch6wGxZYyuOVAxlM9vamJ3uhmN430IpaczLB3VFE61nJEsiP2MYIEkzCCBI8C
# AQEwgYcweTELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEG
# A1UEAxMaTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0ECCmEPeE0AAAAAAAMwCQYF
# Kw4DAhoFAKCBvjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
# AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUY9bQT13aO/1ERhd+
# m4q6LX+trHowXgYKKwYBBAGCNwIBDDFQME6gJoAkAE0AaQBjAHIAbwBzAG8AZgB0
# ACAATABlAGEAcgBuAGkAbgBnoSSAImh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9s
# ZWFybmluZyAwDQYJKoZIhvcNAQEBBQAEggEAcy4FgVSTExjfgwr3dzl5fEyUEg1C
# p8adP7aulV0wOWNzj+Lmk+nEorYWHw0zDepeECbpeDwBmmMMW+P7n9CeJXp59253
# i2aVUABOB9PF5TvWB1epPs5NoDr5sm5jOGnjWlvzYWMp1xuMnB0xVZlJpIZG2u5x
# SEE2t9x7/qemWdyYihS8Z8OFulMeDUycxIdHFxQPfIUZ4htj1D3azmlFcJhhDm+0
# 46r9D/sgoMSrVQeD43uUnAHMZxevNXvtSkC0E9rrTzX+2rrI+Ud5IyYVxmD1eGbI
# dpRTEjFdwuNvlsDY22T21N6ZcPtrFy7a4WsZDaikZ+MNI1qluFXhT+SUG6GCAh8w
# ggIbBgkqhkiG9w0BCQYxggIMMIICCAIBATCBhzB5MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1w
# aW5nIFBDQQIKYUl87QAAAAAABTAHBgUrDgMCGqBdMBgGCSqGSIb3DQEJAzELBgkq
# hkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA4MDEzMTIwNTY0MlowIwYJKoZIhvcN
# AQkEMRYEFGdUOi8+dWKWmpzeQiUBm0882aweMA0GCSqGSIb3DQEBBQUABIIBAIjd
# xXBFEUyQ/lakPSYe4qsj+oU9c2MpdNtxVqMOUEKxlKvaFslie6Du4jUXVcCiSJnZ
# SBq5j+vAQjCzww2m9YWEPiiahwleKVqX3v1MTIkhKFtwhe26AtDo9+/BC7Y3fblw
# S8/nPXYAsynfegaOdNAf3DRnEmTGP08BlhlLDApvJAr8A+7dY8j2ojwr9CSMChlY
# W8LeaLStoHeII7K9e/jbZtwTO9+1XbMpb1SkxLqFaPX3FvhZDgNRWY1tFUHrzOLY
# gfmni9okVijFfW2/CwxE0U9tT1D1I5/H4hygaFInhmiTsnKQ00ZUSeSzcK6ohFg3
# ISGBMkNhRDyKDxFLTss=
# SIG # End signature block
