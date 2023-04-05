# FixLegacyValues.ps1
# PowerShell Version 2 script to fix "Legacy" values of a specified object.
# This allows the object to take advantage of Link Value Replication (LVR)
# for all values after the Forest Functional Level (FFL) is raised from
# Windows 2000 Server to Windows Server 2003 (or above).
#
# Copyright (c) 2015 Richard L. Mueller
#
# ----------------------------------------------------------------------
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the copyright owner above has no warranty, obligations,
# or liability for such use.

# This script prompts for the sAMAccountName or DN of the object, the
# lDAPDisplayName of the attribute,  and a text file containing the output
# from the repadmin command. This file can be created at the command prompt
# of a domain controller with a statement similar to:
# repadmin /showobjmeta mydc "cn=My Object,ou=West,dc=domain,dc=com" > report.txt
# where mydc is the host name of a domain controller and the distinguished
# name is that of the object to be processed. The script processes the values
# in blocks of 4000 at most, to avoid excessive network traffic.

# Version 1.0 - September 2, 2015
# Version 2.0 - September 7, 2015 - Process values in blocks of 4000 at most.
# https://www.rlmueller.net/PowerShell/FixLegacyValues.txt

# Modify the server name to match the DNS Name of a domain controller in your domain.
$Server = mydc.domain.com

# Prompt for the object.
$ADObjectName = Read-Host "Enter the object sAMAccountName or distinguishedName"

Import-Module ActiveDirectory

# Make sure the object exists on the specified domain controller.
$ADObject = $Null
If ($ADObjectName -Like "*,*")
{
    # $ADObjectName is the distinguished name of an object.
    $ADObject = Get-ADObject -Identity $ADObjectName -Server $Server
}
Else
{
    # $ADObjectName is the sAMAccountName of an object.
    $ADObject = Get-ADObject -LDAPFilter "(sAMAccountName=$ADObjectName)" -Server $Server
}
If ($Null -eq $ADObject)
{
    "Object $ADObjectName not found"
    Break
}

# Prompt for the attribute LDAPDisplayName.
$AttrName = Read-Host "Enter the LDAPDisplayName of the attribute to be fixed"

# Prompt for output file from repadmin.
$File = Read-Host "Enter file containing output from repadmin command"

# Retrieve the contents of the file.
$RepAdm = Get-Content $File

$k = 0
$Count = 0
$Total = 0
# Array of attribute values.
$LegacyValues = @()
ForEach ($Line In $RepAdm)
{
    $k = $k + 1
    If ($Line.Length -ge 6)
    {
        # Find lines identifying "Legacy" values of the object.
        # These values cannot take advantage of LVR.
        If ($Line.Substring(0, 6) -eq "LEGACY")
        {
            # Parse this line for the attribute lDAPDisplayName.
            $Attr = $Line.Substring(7).Trim()
            # Only deal with the specified attribute.
            If ($Attr.ToLower() -eq $AttrName.ToLower())
            {
                # Add the value on the next line to the array.
                $Value = $RepAdm[$k + 1].Trim()
                $LegacyValues = $LegacyValues + $Value
                $Count = $Count + 1
                $Total = $Total + 1
                # Process no more than 4000 values at a time.
                If ($Count -eq 4000)
                {
                    # Remove all legacy values from the attribute of the object.
                    Set-ADObject -Identity $ADObject.distinguishedName `
                        -Remove @{$AttrName=$LegacyValues} -Server $Server
                    Start-Sleep -Seconds 10
                    # Add the values back into the object attribute.
                    Set-ADObject -Identity $ADObject.distinguishedName `
                        -Add @{$AttrName=$LegacyValues} -Server $Server
                    # Initialize the array and the counter.
                    $LegacyValues = @()
                    $Count = 0
                    Start-Sleep -Seconds 10
                }
            }
        }
    }
}

# Process any remaining values.
If ($Count -gt 0)
{
    # Remove all legacy values from the attribute of the object.
    Set-ADObject -Identity $ADObject.distinguishedName -Remove @{$AttrName=$LegacyValues} `
        -Server $Server
    Start-Sleep -Seconds 10
    # Add the values back into the object attribute.
    Set-ADObject -Identity $ADObject.distinguishedName -Add @{$AttrName=$LegacyValues} `
        -Server $Server
}

"$Total values of attribute $AttrName of $ADObjectName fixed"