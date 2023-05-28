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

$PrintersGroupbox                = New-Object system.Windows.Forms.Groupbox
$PrintersGroupbox.height         = 188
$PrintersGroupbox.width          = 90
$PrintersGroupbox.Anchor         = 'top,right,left'
$PrintersGroupbox.text           = "Printers"
$PrintersGroupbox.location       = New-Object System.Drawing.Point(25,25)

$UseGroupbox                     = New-Object system.Windows.Forms.Groupbox
$UseGroupbox.height              = 188
$UseGroupbox.width               = 55
$UseGroupbox.Anchor              = 'top,right,left'
$UseGroupbox.text                = "Use"
$UseGroupbox.location            = New-Object System.Drawing.Point(115,25)

$DefaultGroupbox                 = New-Object system.Windows.Forms.Groupbox
$DefaultGroupbox.height          = 188
$DefaultGroupbox.width           = 55
$DefaultGroupbox.Anchor          = 'top,right,left'
$DefaultGroupbox.text            = "Default"
$DefaultGroupbox.location        = New-Object System.Drawing.Point(170,25)

$Printer1                        = New-Object system.Windows.Forms.Label
$Printer1.text                   = "Printer1"
$Printer1.AutoSize               = $true
$Printer1.width                  = 25
$Printer1.height                 = 10
$Printer1.location               = New-Object System.Drawing.Point(35,45)
$Printer1.Font                   = 'Microsoft Sans Serif,10'

$Use1                            = New-Object system.Windows.Forms.CheckBox
$Use1.text                       = ""
$Use1.AutoSize                   = $false
$Use1.width                      = 20
$Use1.height                     = 20
$Use1.location                   = New-Object System.Drawing.Point(134,45)
$Use1.Font                       = 'Microsoft Sans Serif,10'

$Default1                        = New-Object system.Windows.Forms.RadioButton
$Default1.text                   = ""
$Default1.AutoSize               = $false
$Default1.width                  = 20
$Default1.height                 = 20
$Default1.location               = New-Object System.Drawing.Point(190,45)
$Default1.Font                   = 'Microsoft Sans Serif,10'

$Printer2                        = New-Object system.Windows.Forms.Label
$Printer2.text                   = "Printer2"
$Printer2.AutoSize               = $true
$Printer2.width                  = 25
$Printer2.height                 = 10
$Printer2.location               = New-Object System.Drawing.Point(35,65)
$Printer2.Font                   = 'Microsoft Sans Serif,10'

$Use2                            = New-Object system.Windows.Forms.CheckBox
$Use2.AutoSize                   = $false
$Use2.width                      = 20
$Use2.height                     = 20
$Use2.location                   = New-Object System.Drawing.Point(134,65)
$Use2.Font                       = 'Microsoft Sans Serif,10'

$Default2                        = New-Object system.Windows.Forms.RadioButton
$Default2.AutoSize               = $false
$Default2.width                  = 20
$Default2.height                 = 20
$Default2.location               = New-Object System.Drawing.Point(190,65)
$Default2.Font                   = 'Microsoft Sans Serif,10'

$Printer3                        = New-Object system.Windows.Forms.Label
$Printer3.text                   = "Printer3"
$Printer3.AutoSize               = $true
$Printer3.width                  = 25
$Printer3.height                 = 10
$Printer3.location               = New-Object System.Drawing.Point(35,85)
$Printer3.Font                   = 'Microsoft Sans Serif,10'

$Use3                            = New-Object system.Windows.Forms.CheckBox
$Use3.AutoSize                   = $false
$Use3.width                      = 20
$Use3.height                     = 20
$Use3.location                   = New-Object System.Drawing.Point(134,85)
$Use3.Font                       = 'Microsoft Sans Serif,10'

$Default3                        = New-Object system.Windows.Forms.RadioButton
$Default3.AutoSize               = $false
$Default3.width                  = 20
$Default3.height                 = 20
$Default3.location               = New-Object System.Drawing.Point(190,85)
$Default3.Font                   = 'Microsoft Sans Serif,10'

$Cancel                          = New-Object system.Windows.Forms.Button
$Cancel.text                     = "Cancel"
$Cancel.width                    = 60
$Cancel.height                   = 30
$Cancel.Anchor                   = 'top,right,bottom,left'
$Cancel.location                 = New-Object System.Drawing.Point(27,340)
$Cancel.Font                     = 'Microsoft Sans Serif,10'

$OK                              = New-Object system.Windows.Forms.Button
$OK.text                         = "OK"
$OK.width                        = 60
$OK.height                       = 30
$OK.location                     = New-Object System.Drawing.Point(176,340)
$OK.Font                         = 'Microsoft Sans Serif,10'

$SelectPrinters.controls.AddRange(@($Printer1,$Use1,$Default1,$Printer2,$Use2,$Default2,$Printer3,$Use3,$Default3,$PrintersGroupbox,$UseGroupbox,$DefaultGroupbox,$OK,$Cancel))

#region gui events {
#endregion events }

#endregion GUI }


#Write your logic code here
#Add Button event 
$Cancel.Add_Click(
    {    
	#[environment]::exit(0) #Close Everything
    #[System.Windows.Forms.Application]::Exit($null) #Close Window

    }
)
$OK.Add_Click(
    {    
    

    }
)


[void]$SelectPrinters.ShowDialog()