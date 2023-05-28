<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI{ 

$SelectPrinters                  = New-Object system.Windows.Forms.Form
$SelectPrinters.ClientSize       = '642,438'
$SelectPrinters.text             = "Select Printers"
$SelectPrinters.TopMost          = $false

$Use1                            = New-Object system.Windows.Forms.RadioButton
$Use1.text                       = "Use"
$Use1.AutoSize                   = $true
$Use1.width                      = 104
$Use1.height                     = 20
$Use1.location                   = New-Object System.Drawing.Point(135,24)
$Use1.Font                       = 'Microsoft Sans Serif,10'

$Default1                        = New-Object system.Windows.Forms.RadioButton
$Default1.text                   = "Default"
$Default1.AutoSize               = $true
$Default1.width                  = 104
$Default1.height                 = 20
$Default1.location               = New-Object System.Drawing.Point(186,24)
$Default1.Font                   = 'Microsoft Sans Serif,10'

$Use2                            = New-Object system.Windows.Forms.RadioButton
$Use2.text                       = "Use"
$Use2.AutoSize                   = $true
$Use2.width                      = 104
$Use2.height                     = 20
$Use2.location                   = New-Object System.Drawing.Point(136,53)
$Use2.Font                       = 'Microsoft Sans Serif,10'

$Default2                        = New-Object system.Windows.Forms.RadioButton
$Default2.text                   = "Default"
$Default2.AutoSize               = $true
$Default2.width                  = 104
$Default2.height                 = 20
$Default2.location               = New-Object System.Drawing.Point(187,53)
$Default2.Font                   = 'Microsoft Sans Serif,10'

$Cencel                          = New-Object system.Windows.Forms.Button
$Cencel.text                     = "Cancel"
$Cencel.width                    = 60
$Cencel.height                   = 30
$Cencel.Anchor                   = 'top,right,bottom,left'
$Cencel.location                 = New-Object System.Drawing.Point(27,337)
$Cencel.Font                     = 'Microsoft Sans Serif,10'

$OK                              = New-Object system.Windows.Forms.Button
$OK.text                         = "OK"
$OK.width                        = 60
$OK.height                       = 30
$OK.location                     = New-Object System.Drawing.Point(176,338)
$OK.Font                         = 'Microsoft Sans Serif,10'

$Printer2                        = New-Object system.Windows.Forms.Label
$Printer2.text                   = "Printer2"
$Printer2.AutoSize               = $true
$Printer2.width                  = 25
$Printer2.height                 = 10
$Printer2.location               = New-Object System.Drawing.Point(63,53)
$Printer2.Font                   = 'Microsoft Sans Serif,10'

$Printer1                        = New-Object system.Windows.Forms.Label
$Printer1.text                   = "Printer1"
$Printer1.AutoSize               = $true
$Printer1.width                  = 25
$Printer1.height                 = 10
$Printer1.location               = New-Object System.Drawing.Point(64,24)
$Printer1.Font                   = 'Microsoft Sans Serif,10'

$SelectPrinters.controls.AddRange(@($Use1,$Default1,$Use2,$Default2,$Cencel,$OK,$Printer2,$Printer1))

#region gui events {
#endregion events }

#endregion GUI }


#Write your logic code here

[void]$SelectPrinters.ShowDialog()