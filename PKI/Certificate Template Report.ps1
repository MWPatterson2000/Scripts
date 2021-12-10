$date = get-date -Format "yyyy-MM-dd-HH-mm"
certutil -v -template >.\$date-CertificateTemplate-Report.txt
