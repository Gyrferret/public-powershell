$IPAddre = Read-Host Enter a number #Prompts to enter the IP Address
[int]$mask = Read-Host Enter a netmask #Prompts to enter the subnet (e.g. /14, /22)
[int]$sub = 8 #Sets one of our constant variables
$remainder = $null #establishes a variable and sets its value to $null for now
$SimOctets = [math]::DivRem($mask,$sub,[ref]$remainder) #Determines the amount similar octets the IP address has
$subnet = [math]::Pow(2,($remainder)) #Determines the subnet mask
$InvSub = [math]::Pow(2,(8 - $remainder)) #determines the inverse subnet mask 
$GateIP = ([math]::floor(($number / $function))) * $function + 1 #determines the subnet mask
######################################
##Logic for Determining Subnet Masks##
######################################








##################################
##Logic for Determining Gateways##
##################################
if ($final -lt 3) #if condition to set the final octet as .1 if netmask less than a /24
     {
        $Gateway = (([string]"255.") * $final)+ $GateIP + (([String]".0")*(2 - $final)) + [String]".1" #creates the gateway of any subnets less than a /24
    } else { 
        $Gateway = (([string]"255.") * $final)+ $GateIP + (([String]".0")*(3 - $final)) #creates the gateway of any subnets greater= than or eaqual to a /24
        }
$Gateway
Write-Output "$final, Final octet of the Ip is $GatewayIP" 


$subnet1 = [math]::Pow(2,($a)) + [math]::Pow(2,($a))