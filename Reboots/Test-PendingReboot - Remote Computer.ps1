[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ComputerName,
	
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [pscredential]$Credential
)

$ErrorActionPreference = 'Stop'

$scriptBlock = {

    $VerbosePreference = $using:VerbosePreference
    function Test-RegistryKey {
        [OutputType('bool')]
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Key
        )
    
        $ErrorActionPreference = 'Stop'

        if (Get-Item -Path $Key -ErrorAction Ignore) {
            $true
        }
    }

    function Test-RegistryValue {
        [OutputType('bool')]
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Key,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Value
        )
    
        $ErrorActionPreference = 'Stop'

        if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
            $true
        }
    }

    function Test-RegistryValueNotNull {
        [OutputType('bool')]
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Key,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Value
        )
    
        $ErrorActionPreference = 'Stop'

        if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
            $true
        }
    }

    # Added "test-path" to each test that did not leverage a custom function from above since
    # an exception is thrown when Get-ItemProperty or Get-ChildItem are passed a nonexistant key path
    $tests = @(
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
        { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
        { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting' }
        { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations' }
        { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2' }
        { 
            # Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
            'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { test-path $_ -PathType Container } | ForEach-Object {            
                (Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0 
            }
        }
        { Test-RegistryValue -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Value 'DVDRebootSignal' }
        { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps' }
        { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
        { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
        {
            # Added test to check first if keys exists, if not each group will return $Null
            # May need to evaluate what it means if one or both of these keys do not exist
            ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { test-path $_ } | % { (Get-ItemProperty -Path $_ ).ComputerName } ) -ne 
            ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | % { (Get-ItemProperty -Path $_ ).ComputerName } )
        }
        {
            # Added test to check first if key exists
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending' | Where-Object { 
                (Test-Path $_) -and (Get-ChildItem -Path $_) } | ForEach-Object { $true }
        }
    )

    foreach ($test in $tests) {
        Write-Verbose "Running scriptblock: [$($test.ToString())]"
        if (& $test) {
            $true
            break
        }
    }
}

foreach ($computer in $ComputerName) {
    try {
        $connParams = @{
            'ComputerName' = $computer
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $connParams.Credential = $Credential
        }

        $output = @{
            ComputerName    = $computer
            IsPendingReboot = $false
        }

        $psRemotingSession = New-PSSession @connParams
        
        if (-not ($output.IsPendingReboot = Invoke-Command -Session $psRemotingSession -ScriptBlock $scriptBlock)) {
            $output.IsPendingReboot = $false
        }
        [pscustomobject]$output
    }
    catch {
        Write-Error -Message $_.Exception.Message
    }
    finally {
        if (Get-Variable -Name 'psRemotingSession' -ErrorAction Ignore) {
            $psRemotingSession | Remove-PSSession
        }
    }
}