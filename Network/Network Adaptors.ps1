# Get detailed list of network adapters with status and configuration
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MediaConnectionState, AdminStatus

# Function to disable network adapter with error handling
function Disable-NetworkAdapter {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AdapterName
    )
    
    try {
        Disable-NetAdapter -Name $AdapterName -Confirm:$false -ErrorAction Stop
        Write-Host "Successfully disabled adapter: $AdapterName" -ForegroundColor Green
    }
    catch {
        Write-Host "Error disabling adapter $AdapterName : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to enable network adapter with error handling
function Enable-NetworkAdapter {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AdapterName
    )
    
    try {
        Enable-NetAdapter -Name $AdapterName -Confirm:$false -ErrorAction Stop
        Write-Host "Successfully enabled adapter: $AdapterName" -ForegroundColor Green
    }
    catch {
        Write-Host "Error enabling adapter $AdapterName : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Get detailed IP configuration
function Get-NetworkAdapterDetails {
    param(
        [Parameter(Mandatory = $false)]
        [string]$AdapterName
    )

    if ($AdapterName) {
        Get-NetIPConfiguration -Detailed | Where-Object { $_.InterfaceAlias -eq $AdapterName }
    }
    else {
        Get-NetIPConfiguration -Detailed
    }
}

# Example usage:
# List all adapters with details
Get-NetworkAdapterDetails

# Disable specific adapter
Disable-NetworkAdapter -AdapterName 'Docking Station'

# Enable specific adapter
Enable-NetworkAdapter -AdapterName 'Docking Station'