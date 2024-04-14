
# Write-Debug
Write-Debug 'Cannot open file.'

$DebugPreference
SilentlyContinue
Write-Debug 'Cannot open file.'

$DebugPreference = 'Continue'
Write-Debug 'Cannot open file.'


# Write-Error
Write-Error 'Access denied.'

Write-Error -Message 'Error: Too many input values.' -Category InvalidArgument


# Write-Host
Write-Host 'no newline test ' -NoNewline
Write-Host 'second string'
Write-Host 'Red on white text.' -ForegroundColor red -BackgroundColor white


# Write-Information
Write-Information


# Write-Output
$P = Get-Process
Write-Output $P

Write-Output 'test output' | Get-Member

Write-Output 1, 2, 3 | Measure-Object

Write-Output 1, 2, 3 -NoEnumerate | Measure-Object


# Write-Progress
for ($i = 1; $i -le 100; $i++ ) {
    Write-Progress -Activity 'Search in Progress' -Status "$i% Complete:" -PercentComplete $i
    Start-Sleep -Milliseconds 250
}


# Write-Verbose
Write-Verbose -Message 'Searching the Application Event Log.'
Write-Verbose -Message 'Searching the Application Event Log.' -Verbose

$VerbosePreference = 'Continue'
Write-Verbose "Copying file $filename"


# Write-Warning
$WarningPreference
Continue
Write-Warning 'This is only a test warning.'

$WarningPreference = 'SilentlyContinue'
Write-Warning 'This is only a test warning.'

$WarningPreference = 'Stop'
Write-Warning 'This is only a test warning.'
Write-Warning: The running command stopped because the preference variable 'WarningPreference' or common parameter is set to Stop: This is only a test warning.

Write-Warning 'This is only a test warning.' -WarningAction Inquire
