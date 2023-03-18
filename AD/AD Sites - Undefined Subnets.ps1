<#
Name: AD Sites - Undefined Subnets.ps1

This script looks for undefined subnets in the netlogon.log on all DC's and reports them out for X Days.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2018-07-19 - Initial Release

#>

# Clear Screen
Clear-Host

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Set Variables
# Set Search Days
$days = '90'
# Set Array
$AllMissingEntry = @{}
# Counter
$count = 0

#<#
# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "C:\"
$logFolder = "Temp\"
$logFolderPath = $logRoot +$logFolder
$logFile = "Undefined Subnets.csv"
$logFileName = $date +"-" +$logFile 
$logPath = $logRoot +$logFolder +$date +"-" +$logFile
#>

# Get DC's
$DCs = Get-ADDomainController -Filter * | Select-Object name 

foreach ($DC in $DCs) {
    $count = $count + 1
    
    # Search Back X days on DC
    $DomainController = $DC.name
    $FromDate = (Get-Date).AddDays(-$days)
    $Content = Get-Content "\\$DomainController\c$\Windows\Debug\netlogon.log"

    # Run through the netlogon.log (in reverse order, think about speed/performance) while the dates are greater than $FromDate
    $MissingEntry = @{}
    For ($counter = $Content.Count; $counter -ge 0; $counter--) {
        If ($Content[$counter] -match "(\d\d)/(\d\d) (\d\d):(\d\d):(\d\d)") {
            $EntryDate = Get-Date -Month $matches[1] -Day $matches[2] -Hour $Matches[3] -Minute $Matches[4] -Second $Matches[5]
            if ($EntryDate -lt $FromDate) {
                break
            }
            # Within the timeframe, let's save the IP and Date attempted in a hashtable. Only keep the first hit, which is the latest failed site attempt
            $ip = $Content[$counter] -Replace ".* (.*)$", '$1'
            If ($null -eq $MissingEntry[$ip]) {
                $MissingEntry[$ip] = $EntryDate
            }
        }
    }

    # Sort the missing IPs
    $MissingEntry = $MissingEntry.GetEnumerator() | Sort-Object -Property Name

    # Output the missing IPs and failed date attempt
    $MissingEntryT = $MissingEntry | Select-Object @{name="DC"; expression={$DomainController}}, @{name="IP"; expression={$_.Name}}, @{name="Last Failed Site Attempt"; expression={$_.Value}}
    If ($count -eq 1) {
        $AllMissingEntry = $MissingEntryT
        }
        Else {
            $AllMissingEntry = $AllMissingEntry + $MissingEntryT
        }
    }
$AllMissingEntry | Sort-Object -Property IP | Export-Csv $logPath -NoTypeInformation
