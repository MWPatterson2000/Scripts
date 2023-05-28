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

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 100
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(24,20)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'

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

$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 100
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(24,49)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'

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

$SelectPrinters.controls.AddRange(@($TextBox1,$Use1,$Default1,$Use2,$Default2,$TextBox2,$Cencel,$OK))

#region gui events {
#endregion events }

#endregion GUI }


#Write your logic code here

[void]$SelectPrinters.ShowDialog()