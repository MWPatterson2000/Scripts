#requires -Version 3.0
if ($host.name -eq 'Windows PowerShell ISE Host') {
    function Set-ScriptSignature {
    <#
    .SYNOPSIS
    Signs the current file in the ISE with the user's code-signing certificate. You
    must have a valid code-signing certificate in your personal certificate store
    for this to work. Prompts for save location if the file has not yet been saved.
    .NOTES 
    Author: Matt McNabb
    Date: 8/22/2014 
    DISCLAIMER: This script is provided 'AS IS'. It has been tested for personal use, please  
    test in a lab environment before using in a production environment.
    #> 
    
    function Get-FileSavePath {
        $SaveDialog = New-Object -TypeName System.Windows.Forms.SaveFileDialog
        $SaveDialog.Filter = 'Powershell Files(*.ps1;*.psm1;*.psd1;*.ps1xml;*.pssc*;*.cdxml)|*.ps1;*.psm1;*.psd1;*.ps1xml;*.pssc*;*.cdxml|All files (*.*)|*.*'
        $SaveDialog.FilterIndex = 1
        $SaveDialog.RestoreDirectory = $true
        $SaveDialog.ShowDialog()
        $SaveDialog.FileName
    }
    
        $File = $psise.CurrentFile
        $Path = $File.FullPath
        $Certificate = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert
        if ($Certificate)
        {
            if ($File.IsUntitled)
            {
                $Path = Get-FileSavePath
                $File.SaveAs($Path,[text.encoding]::utf8)
            }
            if (-not($File.IsSaved)) {$File.Save([text.encoding]::utf8)}
            Add-Content -Path $Path -Value ''
            Set-AuthenticodeSignature -FilePath $Path -Certificate $Certificate | Out-Null
            $psise.CurrentPowerShellTab.Files.Remove($File) | Out-Null
            $psise.CurrentPowerShellTab.Files.Add($Path) | Out-Null
        }
        else {throw 'A valid code-signing certificate could not be found!'} 
    }
    
    $psISE.CurrentPowerShellTab.AddOnsMenu.submenus.add(“Sign Script”, {Set-ScriptSignature},$null) | Out-Null
}