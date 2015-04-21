function Get-IPInfo {
param (
    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
            [Alias('IP')]
            [STRING[]]$IPAddress,
    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
            [Alias('Mask')]
            [int[]]$Netmask,
            [String]$logfile = 'C:\Windows\Logs\Scripts\Get-IPInfoErrors.txt'#Specifies the default locaiton of the error file
        )
BEGIN{
    if (!(test-path $logfile)) #tests path of log file
       { 
        try { 
            New-Item $logfile -ea SilentlyContinue #attempts to make one if one isn't present
            } catch {
            Write-Output "Unable to create Log File" #message if unable to make one
            }
        } else {
        try {
            Remove-Item $logfile -ea SilentlyContinue #attempts to remove one if present
            New-Item $logfile -ea SilentlyContinue #attempts to make one after removal
            } catch {
            Write-Output "Unable to remove old log file, or create new one" #message if unable to do either
            }
        } #end of if statement
    } #end of BEGIN
PROCESS{
$IPAddr = "71.6.167.73"#Read-Host Enter a number #Prompts to enter the IP Address
[int]$mask = Read-Host Enter a netmask #Prompts to enter the subnet (e.g. /14, /22)
#$IPTest + "8.8.8.8" //To be used later for validation
#if ([IPAddress]::TryParse($Ipaddr,[ref]$IPtest)) //To be used later for validation
$IPSplit = $IPAddr.Split(".")
$remainder = $null #establishes a variable and sets its value to $null for now
$SimOctets = [math]::DivRem($mask,8,[ref]$remainder) #Determines the amount similar octets the IP address has
$InvSub = [math]::Pow(2,(8 - $remainder)) #determines the inverse subnet mask (Old Method)
$Subnet = (256 - [math]::Pow(2,(8 - $remainder))) # Determines subnet mask (New Method)
$UsableIP = [Math]::pow(2,(((3-$simOctets)*8) + (8 - $remainder))) - 2 #Calculates the number of usable IPs in the subnet
#$TestIP = (([math]::floor(($IPSplit[$SimOctets] / $InvSub))) * $InvSub) #determines the subnet mask (Old Method)
If ((([math]::floor(($IPSplit[$SimOctets] / $InvSub))) * $InvSub) -eq $IPSplit[$SimOctets]) #Tests to see if the subnet starts on the current IP.
    {$GateIP = ([math]::floor(($IPSplit[$SimOctets] / $InvSub))) * $InvSub
    } else { 
    $GateIP = ([math]::floor(($IPSplit[$SimOctets] / $InvSub))) * $InvSub + 1}
#$SimOctets,$IPSplit[$SimOctets],$InvSub,$GateIP,$InvSub #Used as a checkpoint to view variable; comment out otherwise
######################################
##Logic for Determining Subnet Masks##
######################################
#Clear-Variable subnet #clears the subnet variable, or else it will be inaccurate on subsequent runs of this script within the same session. Comment-out otherwise.
if ($SimOctets -lt 3) #if condition to set the final octet as .1 if netmask less than a /24
     {
        $SubnetMask = (([string]"255.") * $SimOctets)+ $subnet + (([String]".0")*(3 - $SimOctets)) #creates the gateway of any subnets less than a /24
    } else { 
        $Subnetmask = (([string]"255.") * $SimOctets)+ $subnet #creates the gateway of any subnets greater= than or equal to a /24
        }
#$SubnetMask #Used as a checkpoint to view variable; comment out otherwise
#Clear-Variable subnet #clears the subnet variable, or else it will be inaccurate on subsequent runs of this script within the same session. Comment-out otherwise.
################################
##Logic for Determining Ranges##
################################
$SimIP = $null
For ( $b = ($SimOctets - $SimOctets); $b -lt $SimOctets; $b++)
    { 
        $SimIP += $IPSplit[$b] + "." 
    }
if ($SimOctets -lt 3)
    {
    $FinalIP = $SimIP + [String]($GateIP + $InvSub - 1) + (([String]".0")*(2 - $SimOctets)) + ([String]".254")
    $Gateway = $SimIP + [String]$GateIP + (([String]".0")*(2 - $SimOctets)) + ([String]".1")
    $BroadIP = $SimIP + [String]($GateIP + $InvSub - 1) + (([String]".0")*(2 - $SimOctets)) + ([String]".255")
        } else
    {
    $Gateway = $SimIP + $GateIP
    $FinalIP = $SimIP + ($GateIP + $InvSub - 3)
    $BroadIP = $SimIP + ($GateIP + $InvSub - 2)
    }
      #Clear-Variable c #,d,IPSplit


$PC = New-Object -TypeName PSObject
$PC | Add-Member -MemberType NoteProperty -name "IP Address" -value $IPAddr 
$PC | Add-Member -MemberType NoteProperty -name "Subnet Mask" -value $mask
$PC | Add-Member -MemberType NoteProperty -name "Netmask" -value $SubnetMask
$PC | Add-Member -MemberType NoteProperty -name  "First Usable IP" -value $Gateway
$PC | Add-Member -MemberType NoteProperty -name "Last Usable IP" $FinalIP
$PC | Add-Member -MemberType NoteProperty -name "IP Range" -value $FinalIP
$PC | Add-Member -MemberType NoteProperty -name "Broadcast IP"  -value $BroadIP
$PC | Add-Member -MemberType NoteProperty -name "Usable IPs" -value $UsableIP
$PC | select *

} #End of PROCESS