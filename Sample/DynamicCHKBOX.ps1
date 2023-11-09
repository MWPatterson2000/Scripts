﻿#Generated Form Function
function GenerateForm {
########################################################################
# Code Generated By: Tzahi Kolber v1.0.10.0
# Generated On: 05/10/2020 20:46
# Generated By: TKOLBER
########################################################################

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

$button1_OnClick = {
 $Getsvclist.Text | Out-GridView
 }

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$Getsvclist = New-Object System.Windows.Forms.ListBox
$button1 = New-Object System.Windows.Forms.Button
$ACTcheckBox = New-Object System.Windows.Forms.CheckBox
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 263
$System_Drawing_Size.Width = 372
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.Text = "Dynamic checkbox example"


$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,1,3,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 246
$System_Drawing_Point.Y = 171
$button1.Location = $System_Drawing_Point
$button1.Name = "button1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 55
$System_Drawing_Size.Width = 75
$button1.Size = $System_Drawing_Size
$button1.TabIndex = 2
$button1.Text = "EXPORT"
$button1.UseVisualStyleBackColor = $True
$button1.add_Click($button1_OnClick)
$form1.Controls.Add($button1)


$Getsvclist.DataBindings.DefaultDataSourceUpdateMode = 0
$Getsvclist.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 41
$Getsvclist.Location = $System_Drawing_Point
$Getsvclist.Name = "Getsvclist"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 95
$System_Drawing_Size.Width = 276
$Getsvclist.Size = $System_Drawing_Size
$Getsvclist.TabIndex = 1
$form1.Controls.Add($Getsvclist)


$ACTcheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ACTcheckBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,1,3,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 171
$ACTcheckBox.Location = $System_Drawing_Point
$ACTcheckBox.Name = "ACTcheckBox"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 186
$ACTcheckBox.Size = $System_Drawing_Size
$ACTcheckBox.TabIndex = 0
$ACTcheckBox.Text = "Include Service Status"
$ACTcheckBox.UseVisualStyleBackColor = $True
$form1.Controls.Add($ACTcheckBox)

$Getsvc = (get-service).Name
$Getsvclist.Items.AddRange($Getsvc)
$Getsvclist.SelectedIndex = 0

                                    
$ACTcheckBox.Add_CheckStateChanged({
            [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor
            $Getsvclist.Items.Clear()
                         If ($ACTcheckBox.Checked)
                            {$Getservices = get-service | Select-Object name,status
                                        $h = $Getservices -replace ‘[{},@]’
                                        $k = $h -replace 'Name='
                                        $Getsvc = @($k)
                            }
                         Else {$Getsvc = (get-service).Name}
            $Getsvclist.Items.AddRange($Getsvc) 
            $Getsvclist.SelectedIndex = 0
            [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default
                   })  

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm
