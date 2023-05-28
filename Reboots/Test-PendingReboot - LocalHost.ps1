function Test-RegistryKey {
    [OutputType('bool')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Key
    )
    
    Write-Host $Key
    $ErrorActionPreference = 'Stop'

    if (Get-Item -Path $Key -ErrorAction Ignore) {
        Write-Host "`t"$Key -ForegroundColor Red
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
    
    Write-Host $Key
    $ErrorActionPreference = 'Stop'

    if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
        Write-Host "`t"$Key -ForegroundColor Red
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
    
    Write-Host $Key
    $ErrorActionPreference = 'Stop'

    if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
        Write-Host "`t"$Key -ForegroundColor Red
        $true
    }
}

# Added "test-path" to each test that did not leverage a custom function from above since
# an exception is thrown when Get-ItemProperty or Get-ChildItem are passed a nonexistant key path
$tests = @(
    { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
    { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
    { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
    { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
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
    { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttempts' }
    { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
    { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
    {
        # Added test to check first if keys exists, if not each group will return $Null
        # May need to evaluate what it means if one or both of these keys do not exist
        ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { test-path $_ } | ForEach-Object { (Get-ItemProperty -Path $_ ).ComputerName } ) -ne 
        ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | ForEach-Object { (Get-ItemProperty -Path $_ ).ComputerName } )
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


