# Password Input
$form = New-Object System.Windows.Forms.Form

# Password Input
$password = New-Object Windows.Forms.MaskedTextBox
$password.Size = New-Object System.Drawing.Size(200,20)
$password.PasswordChar = '*'
$password.Top  = 50
$password.Left = 200
$form.Controls.Add($password)

# Title
$form.Text = 'Validate'
$form.Size = New-Object System.Drawing.Size(500,200)
$form.StartPosition = 'CenterScreen'
$form.AutoSize = $true

# OK Button
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Size = New-Object System.Drawing.Size(100,30)
$OKButton.Top  = 100
$OKButton.Left = 250
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

# Text label 
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(50,50)
$label.Size = New-Object System.Drawing.Size(200,20)
$label.Text = 'Enter Your Password :'
$form.Controls.Add($label)

# Show Form
$res = $form.ShowDialog()

if ($res -eq 'OK')
{
  Write-Host "Password Entered"

  # $password.Text can be used for validation logic
}

Write-Host $password.Text
