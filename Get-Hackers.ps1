$event = Get-EventLog -LogName Security -InstanceId 4625 -Newest 1 
foreach($events in $event)
   { 
     $regexp = '\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3}'
     ($events.message |Select-String -Pattern $regexp).Matches.Value >> C:\IPs.txt 
     }


New-NetFirewallRule -DisplayName RDP-TCP-Block -Action Block -Direction Inbound -Enabled True -Profile Any -Protocol TCP -RemotePort 3389
New-NetFirewallRule -DisplayName RDP-UPD-Block -Action Block -Direction Inbound -Enabled True -Profile Any -Protocol UDP -RemotePort 3389
Start-Sleep -Seconds 10
$RDPTCP = Get-NetFirewallRule | where DisplayName -Like "RDP-TCP-Block"
$RDPUDP = Get-NetFirewallRule | where DisplayName -Like "RDP-UDP-Block"

$RDPTCP.DisplayName
$RDPUDP.DisplayName