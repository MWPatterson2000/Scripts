﻿certutil -view -out "Certificate Effective Date,Certificate Expiration Date,Certificate Template,Serial Number,User Principal Name,Issued Common Name,Email" csv | sort | Out-File "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - Certificates Issued.csv"