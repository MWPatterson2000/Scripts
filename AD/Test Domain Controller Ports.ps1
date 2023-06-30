#$ports = 53,88,135,139,389,464,3268,3269
#$ports = 53,88,135,137,139,389,445,464,636,3268,3269
$ports = 53,88,137,139,389,445,464,636,3268,3269
#$ports | ForEach-Object { tnc COMPUTERNAME -port $_ }
$ports | ForEach-Object { Test-NetConnection COMPUTERNAME -port $_ }

# Get-ADDomainController