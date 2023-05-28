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
$Use1.AutoSize                   = $true
$Use1.width                      = 104
$Use1.height                     = 20
$Use1.location                   = New-Object System.Drawing.Point(133,49)
$Use1.Font                       = 'Microsoft Sans Serif,10'

$Default1                        = New-Object system.Windows.Forms.RadioButton
$Default1.AutoSize               = $true
$Default1.width                  = 104
$Default1.height                 = 20
$Default1.location               = New-Object System.Drawing.Point(184,49)
$Default1.Font                   = 'Microsoft Sans Serif,10'

$Use2                            = New-Object system.Windows.Forms.RadioButton
$Use2.AutoSize                   = $true
$Use2.width                      = 104
$Use2.height                     = 20
$Use2.location                   = New-Object System.Drawing.Point(134,78)
$Use2.Font                       = 'Microsoft Sans Serif,10'

$Default2                        = New-Object system.Windows.Forms.RadioButton
$Default2.AutoSize               = $true
$Default2.width                  = 104
$Default2.height                 = 20
$Default2.location               = New-Object System.Drawing.Point(185,78)
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
$Printer2.location               = New-Object System.Drawing.Point(61,78)
$Printer2.Font                   = 'Microsoft Sans Serif,10'

$Printer1                        = New-Object system.Windows.Forms.Label
$Printer1.text                   = "Printer1"
$Printer1.AutoSize               = $true
$Printer1.width                  = 25
$Printer1.height                 = 10
$Printer1.location               = New-Object System.Drawing.Point(62,49)
$Printer1.Font                   = 'Microsoft Sans Serif,10'

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 188
$Groupbox1.width                 = 55
$Groupbox1.Anchor                = 'top,right,left'
$Groupbox1.text                  = "Default"
$Groupbox1.location              = New-Object System.Drawing.Point(171,26)

$Groupbox2                       = New-Object system.Windows.Forms.Groupbox
$Groupbox2.height                = 188
$Groupbox2.width                 = 45
$Groupbox2.Anchor                = 'top,right,left'
$Groupbox2.text                  = "Use"
$Groupbox2.location              = New-Object System.Drawing.Point(114,26)

$SelectPrinters.controls.AddRange(@($Use1,$Default1,$Use2,$Default2,$Cencel,$OK,$Printer2,$Printer1,$Groupbox1,$Groupbox2))

#region gui events {
#endregion events }

#endregion GUI }


#Write your logic code here

[void]$SelectPrinters.ShowDialog()