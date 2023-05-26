$8dot3Path = 'HKLM:\System\CurrentControlSet\Control\FileSystem'
$8dot3Value = (Get-ItemProperty $8dot3Path).NtfsDisable8dot3NameCreation
switch ($8dot3Value) {
    0        {echo "8dot3 Key Value = $8dot3Value `n`tENBLES 8dot3 name creation for all volumes on the system"}
    1        {echo "8dot3 Key Value = $8dot3Value `n`tDISABLES 8dot3 name creation for all volumes on the system"}
    2        {echo "8dot3 Key Value = $8dot3Value `n`tSETS 8dot3 name creation on a per volume basis"}
    3        {echo "8dot3 Key Value = $8dot3Value `n`tDISABLES 8dot3 name creation for all volumes EXCEPT the system volume"}
    default {echo "Not defined or properly set"}
}