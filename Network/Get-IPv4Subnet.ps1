###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Get-IPv4Subnet.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Calculate a subnet based on an IP-Address and the subnetmask or CIDR
# Repository   :  https://github.com/BornToBeRoot/PowerShell
# https://github.com/BornToBeRoot/PowerShell/blob/master/Module/LazyAdmin/Functions/Network/Get-IPv4Subnet.ps1
###############################################################################################################

<#
    .SYNOPSIS
    Calculate a subnet based on an IP-Address and the subnetmask or CIDR

    .DESCRIPTION
    Calculate a subnet based on an IP-Address within the subnet and the subnetmask or CIDR. The result includes the NetworkID, Broadcast, total available IPs and usable IPs for hosts.
                
    .EXAMPLE
    Get-IPv4Subnet -IPv4Address 192.168.24.96 -CIDR 27
    
    NetworkID     Broadcast      IPs Hosts
    ---------     ---------      --- -----
    192.168.24.96 192.168.24.127  32    30
            
    .EXAMPLE
    Get-IPv4Subnet -IPv4Address 192.168.1.0 -Mask 255.255.255.0 | Select-Object -Property *

    NetworkID : 192.168.1.0
    FirstIP   : 192.168.1.1
    LastIP    : 192.168.1.254
    Broadcast : 192.168.1.255
    IPs       : 256
    Hosts     : 254

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Function/Get-IPv4Subnet.README.md
#>

function Get-IPv4Subnet {
    [CmdletBinding(DefaultParameterSetName = 'CIDR')]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'IPv4-Address which is in the subnet')]
        [IPAddress]$IPv4Address,

        [Parameter(
            ParameterSetName = 'CIDR',
            Position = 1,
            Mandatory = $true,
            HelpMessage = 'CIDR like /24 without "/"')]
        [ValidateRange(0, 31)]
        [Int32]$CIDR,

        [Parameter(
            ParameterSetName = 'Mask',
            Position = 1,
            Mandatory = $true,
            Helpmessage = 'Subnetmask like 255.255.255.0')]
        [ValidateScript({
                if ($_ -match "^(254|252|248|240|224|192|128).0.0.0$|^255.(254|252|248|240|224|192|128|0).0.0$|^255.255.(254|252|248|240|224|192|128|0).0$|^255.255.255.(254|252|248|240|224|192|128|0)$") {
                    return $true
                }
                else {
                    throw "Enter a valid subnetmask (like 255.255.255.0)!"
                }
            })]
        [String]$Mask
    )

    Begin {

    }

    Process {
        # Convert Mask or CIDR - because we need both in the code below
        switch ($PSCmdlet.ParameterSetName) {
            "CIDR" {                          
                $Mask = (Convert-Subnetmask -CIDR $CIDR).Mask            
            }

            "Mask" {
                $CIDR = (Convert-Subnetmask -Mask $Mask).CIDR          
            }              
        }
        
        # Get CIDR Address by parsing it into an IP-Address
        $CIDRAddress = [System.Net.IPAddress]::Parse([System.Convert]::ToUInt64(("1" * $CIDR).PadRight(32, "0"), 2))
    
        # Binary AND ... this is how subnets work.
        $NetworkID_bAND = $IPv4Address.Address -band $CIDRAddress.Address

        # Return an array of bytes. Then join them.
        $NetworkID = [System.Net.IPAddress]::Parse([System.BitConverter]::GetBytes([UInt32]$NetworkID_bAND) -join ("."))
        
        # Get HostBits based on SubnetBits (CIDR) // Hostbits (32 - /24 = 8 -> 00000000000000000000000011111111)
        $HostBits = ('1' * (32 - $CIDR)).PadLeft(32, "0")
        
        # Convert Bits to Int64
        $AvailableIPs = [Convert]::ToInt64($HostBits, 2)

        # Convert Network Address to Int64
        $NetworkID_Int64 = (Convert-IPv4Address -IPv4Address $NetworkID.ToString()).Int64

        # Calculate the first Host IPv4 Address by add 1 to the Network ID
        $FirstIP = [System.Net.IPAddress]::Parse((Convert-IPv4Address -Int64 ($NetworkID_Int64 + 1)).IPv4Address)

        # Calculate the last Host IPv4 Address by subtract 1 from the Broadcast Address
        $LastIP = [System.Net.IPAddress]::Parse((Convert-IPv4Address -Int64 ($NetworkID_Int64 + ($AvailableIPs - 1))).IPv4Address)

        # Convert add available IPs and parse into IPAddress
        $Broadcast = [System.Net.IPAddress]::Parse((Convert-IPv4Address -Int64 ($NetworkID_Int64 + $AvailableIPs)).IPv4Address)

        # Change useroutput ==> (/27 = 0..31 IPs -> AvailableIPs 32)
        $AvailableIPs += 1

        # Hosts = AvailableIPs - Network Address + Broadcast Address
        $Hosts = ($AvailableIPs - 2)
            
        # Build custom PSObject
        $Result = [pscustomobject] @{
            NetworkID = $NetworkID
            FirstIP   = $FirstIP
            LastIP    = $LastIP
            Broadcast = $Broadcast
            IPs       = $AvailableIPs
            Hosts     = $Hosts
        }

        # Set the default properties
        $Result.PSObject.TypeNames.Insert(0, 'Subnet.Information')

        $DefaultDisplaySet = 'NetworkID', 'Broadcast', 'IPs', 'Hosts'

        $DefaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$DefaultDisplaySet)

        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)

        $Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        
        # Return the object to the pipeline
        $Result
    }

    End {

    }
}