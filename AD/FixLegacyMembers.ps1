# FixLegacyMembers.ps1
# PowerShell Version 2 script to fix "Legacy" members of a specified group.
# This allows the group to take advantage of Link Value Replication (LVR)
# for all members after the Forest Functional Level (FFL) is raised from
# Windows 2000 Server to Windows Server 2003 (or above).
#
# Copyright (c) 2015 Richard L. Mueller
#
# ----------------------------------------------------------------------
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the copyright owner above has no warranty, obligations,
# or liability for such use.

# This script prompts for either the sAMAccountName or the distinguished name
# of the group and a text file containing the output from the repadmin command.
# This file can be created at the command prompt of a domain controller
# with a statement similar to:
# repadmin /showobjmeta mydc "cn=My Group,ou=West,dc=domain,dc=com" > report.txt
# where mydc is the host name of a domain controller and the distinguished
# name is that of the group to be processed. The script processes the members
# in blocks of 4000 at most, to avoid excessive network traffic.

# Version 1.0 - September 2, 2015
# Version 2.0 - September 7, 2015 - Process members in blocks of 4000 at most.
# https://www.rlmueller.net/PowerShell/FixLegacyMembers.txt

# Modify the server name to match the DNS Name of a domain controller in your domain.
$Server = mydc.domain.com

# Prompt for the group.
$GroupName = Read-Host "Enter the group sAMAccountName or distinguishedName"

Import-Module ActiveDirectory

# Make sure the group exists on the specified domain controller.
$Group = $Null
$Group = Get-ADGroup -Identity $GroupName -Server $Server
If ($Group -eq $Null)
{
    "Group $GroupName not found"
    Break
}

# Prompt for output file from repadmin.
$File = Read-Host "Enter file containing output from repadmin command"

# Retrieve the contents of the file.
$RepAdm = Get-Content $File

$k = 0
$Count = 0
$Total = 0
# Array of group member DN's.
$LegacyMembers = @()
ForEach ($Line In $RepAdm)
{
    $k = $k + 1
    If ($Line.Length -ge 6)
    {
        # Find lines identifying "Legacy" members of the group.
        # These members cannot take advantage of LVR.
        If ($Line.Substring(0, 6) -eq "LEGACY")
        {
            # Parse this line for the attribute lDAPDisplayName.
            $Attr = $Line.Substring(7).Trim()
            # Ignore if the attribute is not "member".
            If ($Attr.ToLower() -eq "member")
            {
                # Add the member DN on the next line to the array.
                $Member = $RepAdm[$k + 1].Trim()
                $LegacyMembers = $LegacyMembers + $Member
                $Count = $Count + 1
                $Total = $Total + 1
                # Process no more than 4000 members at a time.
                If ($Count -eq 4000)
                {
                    # Remove all legacy members from the group.
                    Remove-ADGroupMember -Identity $GroupName `
                        -Members $LegacyMembers -Server $Server
                    Start-Sleep -Seconds 10
                    # Add the members back into the group.
                    Add-ADGroupMember -Identity $GroupName `
                        -Members $LegacyMembers -Server $Server
                    # Initialize the array and the counter.
                    $LegacyMembers = @()
                    $Count = 0
                    Start-Sleep -Seconds 10
                }
            }
        }
    }
}

# Process any remaining members.
If ($Count -gt 0)
{
    # Remove all legacy members from the group.
    Remove-ADGroupMember -Identity $GroupName -Members $LegacyMembers `
        -Server $Server
    Start-Sleep -Seconds 10
    # Add the members back into the group.
    Add-ADGroupMember -Identity $GroupName -Members $LegacyMembers `
        -Server $Server
}

"$Total values of member attribute of $GroupName fixed"