## Change NetWorkConnection Category to Private
#Requires -RunasAdministrator

Get-NetConnectionProfile |
  Where-Object{ $_.NetWorkCategory -ne 'Private'} |
  ForEach-Object {
    $_
    $_|Set-NetConnectionProfile -NetWorkCategory Private -Confirm
  }