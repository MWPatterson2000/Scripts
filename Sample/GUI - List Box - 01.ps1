<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Printers = import-csv "D:\Downloads\Scripts\GUI - Test\Listbox.txt"
#foreach ($Data in $Printers)
# {
# $First = $Data.Printer
# $Second = $Data.Mfg
# Write-Host "Printer: "$Data.Printer "  Mfg: " $Data.MFG
# }

#region begin GUI{ 

$SelectPrinters                  = New-Object system.Windows.Forms.Form
$SelectPrinters.ClientSize       = '500,270'
$SelectPrinters.text             = "Manage Printers - "
#$SelectPrinters.TopMost          = $false
$SelectPrinters.TopMost          = $True
$SelectPrinters.BringToFront()

$Label                           = New-Object system.Windows.Forms.Label
$Label.text                      = "My Printers"
$Label.AutoSize                  = $true
$Label.width                     = 40
$Label.height                    = 30
$Label.location                  = New-Object System.Drawing.Point(150,10)
$Label.Font                      = 'Microsoft Sans Serif,16'

$Printer1                        = New-Object system.Windows.Forms.Label
$Printer1.text                   = "Printer 1 - Default"
$Printer1.AutoSize               = $true
$Printer1.width                  = 40
$Printer1.height                 = 30
$Printer1.location               = New-Object System.Drawing.Point(35,45)
$Printer1.Font                   = 'Microsoft Sans Serif,12'

$PrinterLB1                      = New-Object system.Windows.Forms.ListBox
$PrinterLB1.text                 = "listBox"
$PrinterLB1.width                = 240
$PrinterLB1.height               = 30
$PrinterLB1.location             = New-Object System.Drawing.Point(175,45)
$PrinterLB1.Font                 = 'Microsoft Sans Serif,12'
foreach ($Data in $Printers)
 {
 $PrinterLB1.Items.Add($Data.Printer)
 #$PrinterLB1.Items.Add($Data.Mfg)
 #Write-Host "Printer: "$Data.Printer "  Mfg: " $Data.MFG
 }

$Printer2                        = New-Object system.Windows.Forms.Label
$Printer2.text                   = "Printer 2"
$Printer2.AutoSize               = $true
$Printer2.width                  = 40
$Printer2.height                 = 30
$Printer2.location               = New-Object System.Drawing.Point(35,85)
$Printer2.Font                   = 'Microsoft Sans Serif,12'

$PrinterLB2                      = New-Object system.Windows.Forms.ListBox
$PrinterLB2.text                 = "listBox"
$PrinterLB2.width                = 240
$PrinterLB2.height               = 30
$PrinterLB2.location             = New-Object System.Drawing.Point(175,85)
$PrinterLB2.Font                 = 'Microsoft Sans Serif,12'
foreach ($Data in $Printers)
 {
 $PrinterLB2.Items.Add($Data.Printer)
 #$PrinterLB2.Items.Add($Data.Mfg)
 #Write-Host "Printer: "$Data.Printer "  Mfg: " $Data.MFG
 }

$Printer3                        = New-Object system.Windows.Forms.Label
$Printer3.text                   = "Printer 3"
$Printer3.AutoSize               = $true
$Printer3.width                  = 40
$Printer3.height                 = 30
$Printer3.location               = New-Object System.Drawing.Point(35,125)
$Printer3.Font                   = 'Microsoft Sans Serif,12'

$PrinterLB3                      = New-Object system.Windows.Forms.ListBox
$PrinterLB3.text                 = "listBox"
$PrinterLB3.width                = 240
$PrinterLB3.height               = 30
$PrinterLB3.location             = New-Object System.Drawing.Point(175,125)
$PrinterLB3.Font                 = 'Microsoft Sans Serif,12'
foreach ($Data in $Printers)
 {
 $PrinterLB3.Items.Add($Data.Printer)
 #$PrinterLB3.Items.Add($Data.Mfg)
 #Write-Host "Printer: "$Data.Printer "  Mfg: " $Data.MFG
 }

$Printer4                        = New-Object system.Windows.Forms.Label
$Printer4.text                   = "Printer 4"
$Printer4.AutoSize               = $true
$Printer4.width                  = 40
$Printer4.height                 = 30
$Printer4.location               = New-Object System.Drawing.Point(35,165)
$Printer4.Font                   = 'Microsoft Sans Serif,12'

$PrinterLB4                      = New-Object system.Windows.Forms.ListBox
$PrinterLB4.text                 = "listBox"
$PrinterLB4.width                = 240
$PrinterLB4.height               = 30
$PrinterLB4.location             = New-Object System.Drawing.Point(175,165)
$PrinterLB4.Font                 = 'Microsoft Sans Serif,12'
foreach ($Data in $Printers)
 {
 $PrinterLB4.Items.Add($Data.Printer)
 #$PrinterLB4.Items.Add($Data.Mfg)
 #Write-Host "Printer: "$Data.Printer "  Mfg: " $Data.MFG
 }

$Cancel                          = New-Object system.Windows.Forms.Button
$Cancel.text                     = "Cancel"
$Cancel.width                    = 100
$Cancel.height                   = 30
$Cancel.Anchor                   = 'top,right,bottom,left'
$Cancel.location                 = New-Object System.Drawing.Point(35,220)
$Cancel.Font                     = 'Microsoft Sans Serif,12'

$OK                              = New-Object system.Windows.Forms.Button
$OK.text                         = "OK"
$OK.width                        = 100
$OK.height                       = 30
$OK.location                     = New-Object System.Drawing.Point(300,220)
$OK.Font                         = 'Microsoft Sans Serif,12'

$SelectPrinters.controls.AddRange(@($Label,$Printer1,$PrinterLB1,$Printer2,$PrinterLB2,$Printer3,$PrinterLB3,$Printer4,$PrinterLB4,$OK,$Cancel))

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
    $chosenPrinter1=$PrinterLB1.SelectedItem
    $chosenPrinter2=$PrinterLB2.SelectedItem
    $chosenPrinter3=$PrinterLB3.SelectedItem
    $chosenPrinter4=$PrinterLB4.SelectedItem
    #Write-Host $chosenPrinter1, $chosenPrinter2, $chosenPrinter3, $chosenPrinter4
    $infoData = "YES:" + $chosenPrinter1 + "`n" + "NO:" + $chosenPrinter2 + "`n" + "NO:" + $chosenPrinter3 + "`n" + "NO:" + $chosenPrinter4
    Write-Host $infoData
    }
)


[void]$SelectPrinters.ShowDialog()