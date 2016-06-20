# Create a summary of failed logins to the user account during the last week.

$Date= Get-date     

$DC= "TSDC1.HQ.TSTS.com" # Go to System Properties and input what you see under computer name

$filePath = "~/Documents/failedLogins/"
if(!(Test-Path $filePath)) {
   md $filePath
}

$Report= $filePath + $(get-date -f MM-dd-yyyy) + ".html"

$HTML=@"
<title>Event Logs Report</title>
<style>
BODY{background-color :#FFFFF}
TABLE{Border-width:thin;border-style: solid;border-color:Black;border-collapse: collapse;}
TH{border-width: 1px;padding: 1px;border-style: solid;border-color: black;background-color: ThreeDShadow}
TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color: Transparent}
</style>
"@

$eventsDC= Get-Eventlog security -Computer $DC -InstanceId 4625 -After (Get-Date).AddDays(-7) |
   Select TimeGenerated,ReplacementStrings |
   % {
     New-Object PSObject -Property @{
      Source_Computer = $_.ReplacementStrings[13] 
      UserName = $_.ReplacementStrings[5]
      IP_Address = $_.ReplacementStrings[19]
      Date = $_.TimeGenerated
    }
   }
   
$dailySummary = Get-Eventlog security -Computer $DC -InstanceId 4625 -After (Get-Date).AddDays(-7) | Group-Object {$_.TimeWritten.Date} | ConvertTo-Html -Property Count,Name



$body = "<H2>The week of " + (Get-Date).AddDays(-7) + "</H2>" + "<p>" + $dailySummary + "</p>"
$eventsDC | ConvertTo-Html -Property Source_Computer,UserName,IP_Address,Date -head $HTML -body $body |
       Out-File $Report 