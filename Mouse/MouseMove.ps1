# Define Variables
$movementSize = 10
$sleepTime = 5

Add-Type -AssemblyName System.Windows.Forms

#<#
Function moveMouse {
    $position = [Windows.Forms.Cursor]::Position
    $position.x += $movementSize
    $position.y += $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Seconds $sleepTime
    $position = [Windows.Forms.Cursor]::Position
    $position.x -= $movementSize
    $position.y -= $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Seconds $sleepTime
    }
#>

#<#
$counter = 1
Do {
    <#
    $position = [Windows.Forms.Cursor]::Position
    $position.x += $movementSize
    $position.y += $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Seconds $sleepTime
    $position = [Windows.Forms.Cursor]::Position
    $position.x -= $movementSize
    $position.y -= $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Seconds $sleepTime
    #>
    moveMouse
    #sleep 1
} Until ($counter = 0)
#>