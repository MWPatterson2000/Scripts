function Refresh-ListView {
	param ([string]$path)
	$script:previousItem = (Get-Item $path).PSParentPath
	$listView1.Items.clear()
	Get-ChildItem $path | % {
		$itm=$listView1.Items.Add($_.name)
        $itm.ImageIndex=if($_.PSIsContainer){0}else{1}
	    $itm.Name = $_.FullName
	}
}

#Generated Form Function
function GenerateForm {
    
    #region Import the Assemblies
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    #endregion

    #region Generated Form Objects
    $form1 = New-Object System.Windows.Forms.Form
    $button2 = New-Object System.Windows.Forms.Button
    $button1 = New-Object System.Windows.Forms.Button
    $listView1 = New-Object System.Windows.Forms.ListView
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    #endregion Generated Form Objects

    #region ImageList for nodes
    $global:imageList = new-Object System.Windows.Forms.ImageList
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 32
    $System_Drawing_Size.Height = 32
    $global:imageList.ImageSize = $System_Drawing_Size
    $image1 = [System.Drawing.Image]::FromFile("C:\scripts\ListViewDemo\folder.ico")
    $image2 = [System.Drawing.Image]::FromFile("c:\scripts\ListViewDemo\file.ico")

    $global:imageList.Images.Add("folder",$image1)
    $global:imageList.Images.Add("file",$image2)
    #endregion

    #----------------------------------------------
    #Generated Event Script Blocks
    #----------------------------------------------
    #Provide Custom Code for events specified in PrimalForms.
    $button1_OnClick= 
    {
    	if ($script:previousItem) {
    		Refresh-ListView $script:previousItem
    	} else {
    		[System.Windows.Forms.MessageBox]::Show("Nothing to go back")
    	}
    }

    $doubleClick= 
    {
    	if ($listView1.SelectedItems[0].ImageIndex -eq 1) {
    		[System.Windows.Forms.MessageBox]::Show("You double clicked a file")
    	} else {
    		Refresh-ListView $listView1.SelectedItems[0].Name
    	}
    }

    $button2_OnClick= 
    {
    	$form1.Close()
    }

    $OnLoadForm_StateCorrection=
    {
    	$form1.WindowState = $InitialFormWindowState
    	$listView1.LargeImageList = $imageList
    	Refresh-ListView "c:\scripts"
    }

    #----------------------------------------------
    #region Generated Form Code
    $form1.Text = "File Demo"
    $form1.Name = "form1"
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 689
    $System_Drawing_Size.Height = 499
    $form1.ClientSize = $System_Drawing_Size

    $button2.TabIndex = 2
    $button2.Name = "button2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 75
    $System_Drawing_Size.Height = 23
    $button2.Size = $System_Drawing_Size
    $button2.UseVisualStyleBackColor = $True

    $button2.Text = "Close"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 602
    $System_Drawing_Point.Y = 459
    $button2.Location = $System_Drawing_Point
    $button2.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2.add_Click($button2_OnClick)

    $form1.Controls.Add($button2)

    $button1.TabIndex = 1
    $button1.Name = "button1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 75
    $System_Drawing_Size.Height = 23
    $button1.Size = $System_Drawing_Size
    $button1.UseVisualStyleBackColor = $True

    $button1.Text = "Back"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 459
    $button1.Location = $System_Drawing_Point
    $button1.DataBindings.DefaultDataSourceUpdateMode = 0
    $button1.add_Click($button1_OnClick)

    $form1.Controls.Add($button1)

    $listView1.UseCompatibleStateImageBehavior = $False
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 664
    $System_Drawing_Size.Height = 440
    $listView1.Size = $System_Drawing_Size
    $listView1.DataBindings.DefaultDataSourceUpdateMode = 0
    $listView1.Name = "listView1"
    $listView1.View = 0
    $listView1.TabIndex = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 13
    $listView1.Location = $System_Drawing_Point
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 32
    $System_Drawing_Size.Height = 32
    $listView1.TileSize = $System_Drawing_Size

    $listView1.add_DoubleClick($doubleClick)

    $form1.Controls.Add($listView1)

    #endregion Generated Form Code

    #Save the initial state of the form
    $InitialFormWindowState = $form1.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $form1.add_Load($OnLoadForm_StateCorrection)
    #Show the Form
    $form1.ShowDialog()| Out-Null

} #End Function

# add a helper
$showWindowAsync = Add-Type –memberDefinition @” 
[DllImport("user32.dll")] 
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow); 
“@ -name “Win32ShowWindowAsync” -namespace Win32Functions –passThru

function Show-PowerShell() { 
     [void]$showWindowAsync::ShowWindowAsync((Get-Process –id $pid).MainWindowHandle, 10) 
}

function Hide-PowerShell() { 
    [void]$showWindowAsync::ShowWindowAsync((Get-Process –id $pid).MainWindowHandle, 2) 
}

Hide-PowerShell
GenerateForm