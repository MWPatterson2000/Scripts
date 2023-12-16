function Convert-VHD {
    <#
    .Synopsis
        Convert all the VHD files from a specified location to VHDX
    .DESCRIPTION
        Convert-VHD retrieves each VHD files from a specified location and compacts each using the native command Optimize-VHD
    .EXAMPLE
        Convert-VHD -Path "C:\MyVMs" -Recurse
        Compacts all the VHDX files from the specified path, including subfolders
    .NOTES
        Last updated on 2021.11.05
    #>
    [CmdletBinding()]
    Param
    (
        # Path to the VHDX files
        [Parameter(ValueFromPipelineByPropertyName, Position = 0)]$Path = (Get-Location).Path,
        # Go through subfolders, if selected
        [Parameter(Position = 1)][switch]$IncludeSubfolders
    )
    Begin {
        $StartTime = Get-Date

        # Search for VHDX files in subfolders?
        if ($IncludeSubfolders) {
            $AllVhd = Get-ChildItem *.vhd -Path $Path -Recurse -ErrorAction SilentlyContinue #| Select-Object *
        }
        else {
            $AllVhd = Get-ChildItem *.vhd -Path $Path -ErrorAction SilentlyContinue #| Select-Object *
        }
        # Are there any VHDX files in the location?
        if ($AllVhd.Count -lt 1) {
            Write-Warning "There is no VHD file to convert in `"$Path`". Make sure that the path is correct and it contains VHD files"
            break
        }
        #Clear-Host
        Write-Verbose "Converting $($AllVhd.Count) VHD files, please wait"
    } #Begin
    
    Process {
        $Stats = foreach ($v in $AllVhd) {
            #<#
            #Write-Host $v.FullName
            #Write-Host $v.Directory
            #Write-Host $v.DirectoryName
            #Write-Host $v.Basename
            $vhdFile = $v.FullName
            Write-Host $vhdFile
            #$vhdxFile = $v.DirectoryName + "\" + $v.Basename + ".vhdx" 
            $vhdxFile = $vhdFile + 'x' 
            Write-Host $vhdxFile
            #Pause
            #convert-vhd -Path $tempS -DestinationPath $tempD
            #Convert-VHD -Path $v.FullName -DestinationPath ( $v.DirectoryName + "\" + $v.Basename + ".vhdx" )
            #Convert-VHD -Path $v.FullName -DestinationPath $vhdxFile
            Convert-VHD -Path $vhdFile -DestinationPath $vhdxFile
            Write-Verbose "Converting $($v.Name)"
            Pause
            #>
            <#
            try {
                Convert-VHD -Path $v.FullName -DestinationPath ( $v.DirectoryName + "\" + $v.Basename + ".vhdx" )
                Write-Verbose "Converting $($v.Name)"
                }
            catch {
                Write-Verbose "Skipping $($v.Name).  "
                }   
            #>
        } #$Stats
    } #Process
    End {
        $Duration = New-TimeSpan -Start $StartTime -End (Get-Date)
        $DurationPretty = $($Duration.Hours).ToString() + 'h:' + $($Duration.Minutes).ToString() + 'm:' + $($Duration.Seconds).ToString() + 's'
        $Stats | Format-Table -Wrap -AutoSize
        Write-Verbose "The operation completed in $DurationPretty"
        Write-Verbose "Disk space saved: $([math]::round($TotalSaved /1Gb, 2)) GB"
    } #End
} #function 


Convert-VHD -Path D:\Hyper-V\ -IncludeSubfolders -Verbose