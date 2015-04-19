$IPAddr = Read-Host Enter a number #Prompts to enter the IP Address
[int]$mask = Read-Host Enter a netmask #Prompts to enter the subnet (e.g. /14, /22)
$IPSplit = $IPAddr.Split(".")
$remainder = $null #establishes a variable and sets its value to $null for now
$SimOctets = [math]::DivRem($mask,8,[ref]$remainder) #Determines the amount similar octets the IP address has
$InvSub = [math]::Pow(2,(8 - $remainder)) #determines the inverse subnet mask (Old Method)
$Subnet = (256 - [math]::Pow(2,(8 - $remainder))) # Determines subnet mask (New Method)
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
##################################
##Logic for Determining Gateways##
##################################
$SimIP = $null
For ( $b = ($SimOctets - $SimOctets); $b -lt $SimOctets; $b++)
    { 
        $SimIP += $IPSplit[$b] + "." 
    }
if ($SimOctets -lt 3)
    {
    $Gateway = $SimIP + [String]$GateIP + (([String]".0")*(2 - $SimOctets)) + ([String]".1")
        } else
    {
    $Gateway = $SimIP + $GateIP
    }
      Clear-Variable c #,d,IPSplit
#Clear-Host

Write-Output "IP Address: $IPAddr /$mask"
Write-Output "Netmask: $SubnetMask"
Write-Output "Gateway IP: $Gateway"