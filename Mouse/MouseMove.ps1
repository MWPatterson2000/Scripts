# Define Variables
$movementSize = 10
$sleepTime = 5

Add-Type -AssemblyName System.Windows.Forms

#<#
Function moveMouse {
    #<#
    # Square
    $position = [Windows.Forms.Cursor]::Position
    $position.x += $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Milliseconds $sleepTime
    $position = [Windows.Forms.Cursor]::Position
    $position.y += $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Milliseconds $sleepTime
    $position = [Windows.Forms.Cursor]::Position
    $position.x -= $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Milliseconds $sleepTime
    $position = [Windows.Forms.Cursor]::Position
    $position.y -= $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Milliseconds $sleepTime
    #>

    <#
    # Diagaional
    #$oposition = [Windows.Forms.Cursor]::Position
    $position = [Windows.Forms.Cursor]::Position
    $position.x += $movementSize
    $position.y += $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Milliseconds $sleepTime
    $position = [Windows.Forms.Cursor]::Position
    $position.x -= $movementSize
    $position.y -= $movementSize
    [Windows.Forms.Cursor]::Position = $position
    Start-Sleep -Milliseconds $sleepTime
    #>
}
#>

#<#
$counter = 1
Do {
    moveMouse
    Start-Sleep -Seconds $sleepTime
} Until ($counter = 0)
#>