<#
Name: Disk Space = eMail.ps1

This script is for checking the Disk info and emailing a report.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2018-10-26 - Initial Release
    2023-11-22 - Converting to Advanced

#>
[CmdletBinding()]
[Alias()]
[OutputType([int])]
Param(
    # Parameter help description
    #[Parameter(AttributeValues)]
    #[ParameterType]
    #$ParameterName
)

Begin {
    # Clear Screen
    Clear-Host

    <#
    # Check For Admin Mode
    #Requires -RunAsAdministrator
    #>

    # Set Variables
    $Header = @'
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
'@

    # Clear Varables
    function Get-UserVariable ($Name = '*') {
        # these variables may exist in certain environments (like ISE, or after use of foreach)
        $special = 'ps', 'psise', 'psunsupportedconsoleapplications', 'foreach', 'profile'

        $ps = [PowerShell]::Create()
        $null = $ps.AddScript('$null=$host;Get-Variable') 
        $reserved = $ps.Invoke() | 
        Select-Object -ExpandProperty Name
        $ps.Runspace.Close()
        $ps.Dispose()
        Get-Variable -Scope Global | 
        Where-Object Name -like $Name |
        Where-Object { $reserved -notcontains $_.Name } |
        Where-Object { $special -notcontains $_.Name } |
        Where-Object Name 
    }
}

Process {
    # Get Disk Info
    $volumes = Get-WmiObject win32_volume -Filter "DriveType='3'" # Single Local Server
    #$volumes = Get-WmiObject win32_volume -computername mfambx1, mfambx2 -Filter "DriveType='3'" # Multiple Server/Remote Server
    $Body = $volumes | Select-Object SystemName, Name, Label, DriveLetter, FileSystem, `
    @{Name = 'Capacity(GB)'; expression = { [math]::round(($_.Capacity / 1073741824), 2) } }, `
    @{Name = 'Used Space(GB)'; expression = { [math]::round((($_.Capacity / 1073741824) - ($_.FreeSpace / 1073741824)), 2) } }, `
    @{Name = 'Free Space(GB)'; expression = { [math]::round(($_.FreeSpace / 1073741824), 2) } }, `
    @{Name = 'Free(%)'; expression = { [math]::round(((($_.FreeSpace / 1073741824) / ($_.Capacity / 1073741824)) * 100), 2) } } `
    | Sort-Object SystemName, DriveLetter, Name | ConvertTo-Html -Head $Header

    # Email Report
    $emailFrom = '<Sender Email Address>' 
    $emailTo = '<Recipient(s) Email Address>'
    #$subject = "Disk Size $env:COMPUTERNAME" 
    $subject = 'Disk Size' 
    $smtpServer = '<SMTP Server>'
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $MailMessage = new-object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body)
    $MailMessage.IsBodyHtml = $true
    #$MailMessage.IsBodyHtml = $false
    $MailMessage.ReplyTo = '<Reply Email Address>'
    $smtp.Send($MailMessage)

}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    Exit
}
