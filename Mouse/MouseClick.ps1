# Build Environment
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
# Define Variables
$sleepTime = 1
#$sleepTime = .25

# Call user32.dll
$signature=@'
[DllImport("user32.dll",CharSet=CharSet.Auto,CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@

# Mouse Event
$SendMouseClick = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru

<#
# Get Mouse Click Location
$X = [System.Windows.Forms.Cursor]::Position.X
$Y = [System.Windows.Forms.Cursor]::Position.Y
Write-Output "X: $X | Y: $Y"
#>

Function leftMouseClick {
    #$x = 109
    #$y = 56
    #[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #sleep -Seconds 1
    $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0);
    $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0);
}

Function rightMouseClick {
    #$x = 109
    #$y = 56
    #[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    #sleep -Seconds 1
    $SendMouseClick::mouse_event(0x00000008, 0, 0, 0, 0);
    $SendMouseClick::mouse_event(0x00000010, 0, 0, 0, 0);
}

#leftMouseClick

#<#
$counter = 1
Do {
    <#
    $position = [Windows.Forms.Cursor]::Position
    $x = $position.x
    $y = $position.y
    #>
    leftMouseClick
    #rightMouseClick
    #sleep 1
    Start-Sleep -Seconds $sleepTime
    #Start-Sleep -Milliseconds $sleepTime
} Until ($counter = 0)
#>

<#
do { 
    $position = [Windows.Forms.Cursor]::Position
    $x = $position.x
    $y = $position.y
    leftMouseClick
    echo "Press F2 to Exit"
    $x = [System.Console]::ReadKey() 
} while( $x.Key -ne "F2" )
#>

<#
 $notpressed = $true
 $i = 0
 while ($notpressed){
     $i++
     if ([console]::KeyAvailable) {
         $notpressed = $false    
     }    
     else {
        leftMouseClick
        sleep 1
     }
 }
#>