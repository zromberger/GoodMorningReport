#version 2 -- for production

$admins = @(
  #[Recipent Addresses Go Here]
  "somedude@somesite.com"
)

$OnSiteServers = @(
  #[Server FQDNs go here]
  "DC01.somecompany.local"
)

#mail
$From = "[Email Address Goes Here]"
$password = '[Email Password Goes Here]' |  Convertto-SecureString -AsPlainText -Force																		   
$Body = ""
$SMTPServer = "[Email Server Goes Here]"
$SMTPPort = 587
$emailcredentials = New-Object -TypeName System.Management.Automation.Pscredential -Argumentlist $from, $password
$subject = ""

$failures = 0

foreach ($server in $OnSiteServers){
    $s = ping $server -n 1
    if($s -like "*Reply*"){
        if($s -like "*unreachable*"){
            $body += "Issue with $server." 
            $body += $s
            $failures++
        } 
        else {
            $body += "$server is UP!"
        }
    } 
    else { 
        $body += "Issue with $server." 
        $body += $s
        $failures++
    }
$body += "`n`n"
}

if($failures -ge 1){
$subject += "ALERT! "
}
$date = Get-Date -UFormat "%A, %D - %r"
$subject += "Good Morning Report: $date"

foreach($admin in $admins){
Send-MailMessage -UseSsl -From $From -To $admin -Subject $Subject -Body $Body `
    -SmtpServer $SMTPServer -port $SMTPPort -Credential ($emailcredentials) `
    –DeliveryNotificationOption OnSuccess
}
