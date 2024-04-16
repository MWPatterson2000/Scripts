<#
.SYNOPSIS
    This script gets the AD Information for the Domain and reports it out.

.DESCRIPTION
    

.PARAMETER


.EXAMPLE


.LINK
    https://github.com/MWPatterson2000/Scripts/

.NOTES
    Change Log:
    Date            Version         By                  Notes
    ----------------------------------------------------------
    2020-08-26      2020-08-26      Mike Patterson      Initial Release
    2023-03-29      2023-03-29      Mike Patterson      Cleanup
    2024-02-15      2024-02-15      Mike Patterson      Added Server 2025 and Forest Info.


    
    VERSION 1.2024.0215
    GUID 
    AUTHOR Michael Patterson
    CONTACT scripts@mwpatterson.com
    COMPANYNAME 
    COPYRIGHT 
    APPLICATION 
    FEATURE 
    TAGS 
    LICENSEURI 
    PROJECTURI 
    RELEASENOTES
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
    # PowerShell 5.x required. The version of PowerShell included with Windows 10
    #Requires -Version 5.0
    #>

    <#
    # PowerShell Version Requirements - v7.2 (LTS) Min
    #$PSVersionTable
    #$PSVersionTable.PSVersion
    #Requires -Version 7.2
#>

    <#
    # Self-elevate the script if required
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
    #>

    <#
    # Check For Admin Mode
    #Requires -RunAsAdministrator
    #>

    <#
    # Hide PowerShell Console
    $Script:showWindowAsync = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'@ -Name 'Win32ShowWindowAsync' -Namespace Win32Functions -PassThru

    Hide-PowerShell
    #>


    # Funtions
    # Start Functions
    # Show PowerShell
    Function Show-Powershell() {
        [CmdletBinding()]
        param ()
        $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
    }

    # Hide Show PowerShell
    Function Hide-Powershell() {
        [CmdletBinding()]
        param ()
        $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
    }


    # Email Function
    #function send_email ($exportPath, $email) 
    function send_email () {
        [CmdletBinding()]
        param ()
        $SmtpClient = new-object system.net.mail.smtpClient 
        $mailmessage = New-Object system.net.mail.mailmessage 
        #    $SmtpClient.EnableSsl = $smtpssl
        #    $SmtpClient.Credentials = New-Object System.Net.NetworkCredential("User", "Password"); 
        $SmtpClient.Host = $smtpserver
        $SmtpClient.Port = $smtpport
        $mailmessage.from = $emailfrom 
        $mailmessage.To.add($email1)
        #    $mailmessage.To.add($email2)
        $mailmessage.Subject = $emailSubject
        #    $mailmessage.Priority = 2 # High
        #    $mailmessage.Priority = 1 # Low
        #    $mailmessage.Priority = 0 # Normal
        $mailmessage.IsBodyHtml = $emailIsBodyHtml
        #    $mailmessage.Attachments.Add($emailFile)
        $mailmessage.Body = $Body

        $smtpclient.Send($mailmessage) 
    }

    # Clear Varables
    function Get-UserVariable ($Name = '*') {
        [CmdletBinding()]
        #param ()
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

    # End Functions

    # Set Variables
    $today = Get-Date
    $today = $today.ToString('dddd MMMM-dd-yyyy hh:mm tt')

    <#
    # Get Date & Log Locations
    $date = get-date -Format "yyyy-MM-dd-HH-mm"
    $logRoot = "<Drive Letter>:\"
    $logFolder = "<Path>\"
    $logFolderPath = $logRoot +$logFolder
    $logFile = "<File Name>.txt"
    $logFileName = $date +"-" +$logFile 
    $logPath = $logRoot +$logFolder +$date +"-" +$logFile
    #>

    <#
    #Configure Email notification recipient
    #$smtpserver = "outlook.office365.com"
    #$smtpport = "587"
    #$smtpssl = "True"
    $smtpserver = '<SMTP Relay Server>'
    $smtpport = '25'
    $smtpssl = 'False'
    $emailSubject = 'Sample Subject'
    $emailIsBodyHtml = $true
    #$emailfrom = "Sender <sender@test.local>"
    $emailfrom = "$env:computername <$env:computername@>"
    $email1 = 'user1@test.local'
    #$email2 = "user2@test.local"
    #$emailFile = $logPath
    #>

    <#
    #File Logging/Output
    *> $logPath #Create Log File
    *>> $logPath #Append to Log File
    | Out-File $logPath #Create Log File
    | Out-File $logPath -Append #Append to Log File
    #>

    <#
    # Email Body
    $Body = @"
<!--<strong>Sample Message $env:USERDOMAIN</strong><br />-->
Sample Message <span style="background-color:yellow;color:black;"><strong>$env:USERDOMAIN</strong></span>.<br /> <br />

Generated on : $today<br /><br />
<br /></font></h5>
"@
    # Send email Notification
    send_email
    #>


    # Get Variables
    #Get-UserVariable
}

Process {
    # Get counts of different types of objects in Active Directory
    $Computers = (Get-ADComputer -Filter * | Measure-Object).Count
    $Workstations = (Get-ADComputer -Filter { Get-OperatingSystem -notlike '*Server*' } | Measure-Object).Count
    $Servers = (Get-ADComputer -Filter { Get-OperatingSystem -like '*Server*' } | Measure-Object).Count
    $Users = (Get-ADUser -Filter * | Measure-Object).Count
    $Groups = (Get-ADGroup -Filter * | Measure-Object).Count
    #$domain = Get-ADDomain | Format-Table Forest
    # Get Forest Info & FSMO roles individually
    $Forest = Get-ADForest
    $ADForest = $Forest.ForestMode
    $SchemaMaster = $Forest.SchemaMaster
    $DomainNamingMaster = $Forest.DomainNamingMaster
    # Get Domain Info & FSMO roles individually
    $Domain = Get-ADDomain
    $ADDomain = $Domain.DomainMode
    $RIDMaster = $Domain.RIDMaster
    $PDCEmulator = $Domain.PDCEmulator
    $InfrastructureMaster = $Domain.InfrastructureMaster
    # Get Forest AD Functional Levels
    $ADDomainFunctionality = (Get-ADRootDSE).domainControllerFunctionality
    #$ADForest = (Get-ADRootDSE).forestFunctionality
    #$ADDomain = (Get-ADRootDSE).domainFunctionality

    $ADVer = Get-ADObject (Get-ADRootDSE).schemaNamingContext -property objectVersion | Select-Object objectVersion
    $ADNUM = $ADVer -replace '@{objectVersion=', '' -replace '}', ''
    If ($ADNum -eq '90') { $srv = 'Windows Server 2025' }
    ElseIf ($ADNum -eq '88') { $srv = 'Windows Server 2019/2022' }
    ElseIf ($ADNum -eq '87') { $srv = 'Windows Server 2016' }
    ElseIf ($ADNum -eq '69') { $srv = 'Windows Server 2012 R2' }
    ElseIf ($ADNum -eq '56') { $srv = 'Windows Server 2012' }
    ElseIf ($ADNum -eq '47') { $srv = 'Windows Server 2008 R2' }
    ElseIf ($ADNum -eq '44') { $srv = 'Windows Server 2008' }
    ElseIf ($ADNum -eq '31') { $srv = 'Windows Server 2003 R2' }
    ElseIf ($ADNum -eq '30') { $srv = 'Windows Server 2003' }
    Write-host 'Active Directory Info' -ForegroundColor Yellow
    Write-Host 'Active Directory Forest Mode = '$ADForest -ForegroundColor Cyan
    Write-Host 'Active Directory Domain Mode = '$ADDomain -ForegroundColor Cyan
    Write-Host 'Active Directory Domain Functionality = '$ADDomainFunctionality -ForegroundColor Cyan
    Write-Host "Active Directory Schema Version is $ADNum which corresponds to $Srv" -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'FSMO Role Owners' -ForegroundColor Yellow
    #$FSMO = netdom query FSMO
    #$FSMO
    # Display FSMO role owners
    Write-Host "Schema Master         =  $SchemaMaster" -ForegroundColor Cyan
    Write-Host "Domain Naming Master  =  $DomainNamingMaster" -ForegroundColor Cyan
    Write-Host "RID Master            =  $RIDMaster" -ForegroundColor Cyan
    Write-Host "PDC Emulator          =  $PDCEmulator" -ForegroundColor Cyan
    Write-Host "Infrastructure Master =  $InfrastructureMaster" -ForegroundColor Cyan
    Write-Host ''
    # Display Computer Information
    Write-Host 'Client Info' -ForegroundColor Yellow
    Write-Host "Computers  = $Computers" -ForegroundColor Cyan
    Write-Host "Workstions = $Workstations" -ForegroundColor Cyan
    Write-Host "Servers    = $Servers" -ForegroundColor Cyan
    Write-Host ''
    # Display User & Groups Information
    Write-Host 'User & Group Info' -ForegroundColor Cyan
    Write-Host "Users      = $Users" -ForegroundColor Cyan
    Write-Host "Groups     = $Groups" -ForegroundColor Cyan
    Write-host ''
    Write-Host 'Active Directory Health Check' -ForegroundColor Yellow
    Write-host ''

    # Get ALL DC Servers
    $getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()
    $DCServers = $getForest.domains | ForEach-Object { $_.DomainControllers } | ForEach-Object { $_.Name }
    $timeout = '60'
    foreach ($DC in $DCServers) {
        $Identity = $DC
        # Ping Test
        if (Test-Connection -ComputerName $DC -Count 1 -ErrorAction SilentlyContinue) {
            Write-Host $DC `t $DC `t Ping Success -ForegroundColor Green
            # Netlogon Service Status
            $serviceStatus = start-job -scriptblock { get-service -ComputerName $($args[0]) -Name 'Netlogon' -ErrorAction SilentlyContinue } -ArgumentList $DC
            wait-job $serviceStatus -timeout $timeout
            if ($serviceStatus.state -like 'Running') {
                Write-Host $DC `t Netlogon Service TimeOut -ForegroundColor Yellow
                stop-job $serviceStatus
            }
            else {
                $serviceStatus1 = Receive-job $serviceStatus
                if ($serviceStatus1.status -eq 'Running') {
                    Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green
                    $svcName = $serviceStatus1.name
                    $svcState = $serviceStatus1.status
                }
                else {
                    Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red
                    $svcName = $serviceStatus1.name
                    $svcState = $serviceStatus1.status
                }
            }
        }
        else {
            Write-Host $DC `t $DC `t Ping Failed -ForegroundColor Red
        }
        # NTDS Service Status
        $serviceStatus = start-job -scriptblock { get-service -ComputerName $($args[0]) -Name 'NTDS' -ErrorAction SilentlyContinue } -ArgumentList $DC
        wait-job $serviceStatus -timeout $timeout
        if ($serviceStatus.state -like 'Running') {
            Write-Host $DC `t NTDS Service TimeOut -ForegroundColor Yellow
            stop-job $serviceStatus
        }
        else {
            $serviceStatus1 = Receive-job $serviceStatus
            if ($serviceStatus1.status -eq 'Running') {
                Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green
                $svcName = $serviceStatus1.name
                $svcState = $serviceStatus1.status
            }
            else {
                Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red
                $svcName = $serviceStatus1.name
                $svcState = $serviceStatus1.status
            }
        }
        # DNS Service Status
        $serviceStatus = start-job -scriptblock { get-service -ComputerName $($args[0]) -Name 'DNS' -ErrorAction SilentlyContinue } -ArgumentList $DC
        wait-job $serviceStatus -timeout $timeout
        if ($serviceStatus.state -like 'Running') {
            Write-Host $DC `t DNS Server Service TimeOut -ForegroundColor Yellow
            stop-job $serviceStatus
        }
        else {
            $serviceStatus1 = Receive-job $serviceStatus
            if ($serviceStatus1.status -eq 'Running') {
                Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green
                $svcName = $serviceStatus1.name
                $svcState = $serviceStatus1.status
            }
            else {
                Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red
                $svcName = $serviceStatus1.name
                $svcState = $serviceStatus1.status
            }
        }
        # Netlogons status
        add-type -AssemblyName microsoft.visualbasic
        $cmp = 'microsoft.visualbasic.strings' -as [type]
        $sysvol = start-job -scriptblock { dcdiag /test:netlogons /s:$($args[0]) } -ArgumentList $DC
        wait-job $sysvol -timeout $timeout
        if ($sysvol.state -like 'Running') {
            Write-Host $DC `t Netlogons Test TimeOut -ForegroundColor Yellow
            stop-job $sysvol
        }
        else {
            $sysvol1 = Receive-job $sysvol
            if ($cmp::instr($sysvol1, 'passed test NetLogons')) {
                Write-Host $DC `t Netlogons Test passed -ForegroundColor Green
            }
            else {
                Write-Host $DC `t Netlogons Test Failed -ForegroundColor Red
            }
        }
        # Replications status
        add-type -AssemblyName microsoft.visualbasic
        $cmp = 'microsoft.visualbasic.strings' -as [type]
        $sysvol = start-job -scriptblock { dcdiag /test:Replications /s:$($args[0]) } -ArgumentList $DC
        wait-job $sysvol -timeout $timeout
        if ($sysvol.state -like 'Running') {
            Write-Host $DC `t Replications Test TimeOut -ForegroundColor Yellow
            stop-job $sysvol
        }
        else {
            $sysvol1 = Receive-job $sysvol
            if ($cmp::instr($sysvol1, 'passed test Replications')) {
                Write-Host $DC `t Replications Test passed -ForegroundColor Green
            }
            else {
                Write-Host $DC `t Replications Test Failed -ForegroundColor Red
            }
        }
        # Services status
        add-type -AssemblyName microsoft.visualbasic
        $cmp = 'microsoft.visualbasic.strings' -as [type]
        $sysvol = start-job -scriptblock { dcdiag /test:Services /s:$($args[0]) } -ArgumentList $DC
        wait-job $sysvol -timeout $timeout
        if ($sysvol.state -like 'Running') {
            Write-Host $DC `t Services Test TimeOut -ForegroundColor Yellow
            stop-job $sysvol
        }
        else {
            $sysvol1 = Receive-job $sysvol
            if ($cmp::instr($sysvol1, 'passed test Services')) {
                Write-Host $DC `t Services Test passed -ForegroundColor Green
            }
            else {
                Write-Host $DC `t Services Test Failed -ForegroundColor Red
            }
        }
        # Advertising status
        add-type -AssemblyName microsoft.visualbasic
        $cmp = 'microsoft.visualbasic.strings' -as [type]
        $sysvol = start-job -scriptblock { dcdiag /test:Advertising /s:$($args[0]) } -ArgumentList $DC
        wait-job $sysvol -timeout $timeout
        if ($sysvol.state -like 'Running') {
            Write-Host $DC `t Advertising Test TimeOut -ForegroundColor Yellow
            stop-job $sysvol
        }
        else {
            $sysvol1 = Receive-job $sysvol
            if ($cmp::instr($sysvol1, 'passed test Advertising')) {
                Write-Host $DC `t Advertising Test passed -ForegroundColor Green
            }
            else {
                Write-Host $DC `t Advertising Test Failed -ForegroundColor Red
            }
        }
        # FSMOCheck status
        add-type -AssemblyName microsoft.visualbasic
        $cmp = 'microsoft.visualbasic.strings' -as [type]
        $sysvol = start-job -scriptblock { dcdiag /test:FSMOCheck /s:$($args[0]) } -ArgumentList $DC
        wait-job $sysvol -timeout $timeout
        if ($sysvol.state -like 'Running') {
            Write-Host $DC `t FSMOCheck Test TimeOut -ForegroundColor Yellow
            stop-job $sysvol
        }
        else {
            $sysvol1 = Receive-job $sysvol
            if ($cmp::instr($sysvol1, 'passed test FsmoCheck')) {
                Write-Host $DC `t FSMOCheck Test passed -ForegroundColor Green
            }
            else {
                Write-Host $DC `t FSMOCheck Test Failed -ForegroundColor Red
            }
        }
        Write-Host ''
    }
}

End {
    # Clear Variables
    #Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue
    
    # Memory Cleanup
    [System.GC]::Collect()

    # End
    #Exit
    return
}

