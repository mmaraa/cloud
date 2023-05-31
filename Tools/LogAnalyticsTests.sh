#Populate 10 CEF 10sec between each
#!/bin/bash
counter=1
while [ $counter -le 10 ]
do
logger -p local4.warn -t CEF "CEF:0|Markus|MLI|0.1|MarkusTests|MarkusTest-$counter|5|"
sleep 10
((counter++))
done


#Check CEF test messages from Common Security Log
CommonSecurityLog
| where DeviceProduct == "MLI"
| sort by TimeGenerated desc 