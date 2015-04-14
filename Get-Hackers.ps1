## This Script gets IP Address of failed authentication attempts

$event = Get-EventLog -LogName Security -InstanceId 4625 -Newest 1 #Gets all events that are 4625 (failed authentication)
foreach($events in $event)
   { 
     $regexp = '\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}' # Regular expression for IP addresses
     ($events.message |Select-String -Pattern $regexp).Matches.Value >> C:\IPs.txt # Uses that regular expression to pull out the IP address within the Event Log Message
     }


New-NetFirewallRule -DisplayName RDP-TCP-Block -Action Block -Direction Inbound -Enabled True -Profile Any -Protocol TCP -RemotePort 3389 #Creates a block rule for RDP (TCP)
New-NetFirewallRule -DisplayName RDP-UPD-Block -Action Block -Direction Inbound -Enabled True -Profile Any -Protocol UDP -RemotePort 3389 #Creates a block rule for RDP (TCP)
Start-Sleep -Seconds 10 #Allows for the rules to be set in case they take a little longer than normal.
$RDPTCP = Get-NetFirewallRule | where DisplayName -Like "RDP-TCP-Block" #Gets the name of the rule that's just been created in order to work with it
$RDPUDP = Get-NetFirewallRule | where DisplayName -Like "RDP-UDP-Block"

$RDPTCP.DisplayName
$RDPUDP.DisplayName