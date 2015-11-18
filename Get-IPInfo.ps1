function Get-IPInfo {
param (
    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               Mandatory=$True)]
            [Alias('IP')]
            [STRING[]]$IPAddress,
    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               Mandatory=$True,
               ParameterSetName="CIDR"
               )]
            [int[]]$CIDR,
    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               Mandatory=$True,
               ParameterSetName="NetMask"
               )]
            [string[]]$NetMask
        )
BEGIN{ #sets switch variable for determining which function to utilize
    $catch = $true 
        if ($NetMask) {
        $catch = $false
        }
    } #end of BEGIN
     
PROCESS{
    $TestIP = "8.8.8.8"
    If ([IPAddress]::TryParse($IPAddress,[ref]$TestIP)){
         Foreach ($IPAddress in $IPAddress) {
            GetIPInfo -IPAddr "$IPAddress" -CIDR "$CIDR"
            }
        } else {
            Write-Output "Please Enter a Valid IP"
        } #End Statement
    } #End of PROCESS

END{} #End of End

}
function GetIPInfo {
param($IPAddr, $CIDR)
$Class = $null
$remainder = $null #establishes a variable and sets its value to $null for now
$IsPrivate = $False
#$IPAddr #= "71.6.167.73"#Read-Host Enter a number #Prompts to enter the IP Address
#$mask #= Read-Host Enter a netmask #Prompts to enter the subnet (e.g. /14, /22)
$IPSplit = $IPAddr.Split(".")
$SimOctets = [math]::DivRem($CIDR,8,[ref]$remainder) #Determines the amount similar octets the IP address has
$InvSub = [math]::Pow(2,(8 - $remainder)) #determines the inverse subnet mask (Old Method)
$Subnet = (256 - [math]::Pow(2,(8 - $remainder))) # Determines subnet mask (New Method)
$UsableIP = [Math]::pow(2,(((3-$simOctets)*8) + (8 - $remainder))) - 2 #Calculates the number of usable IPs in the subnet
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
##############################
##Logic for IP Class/Public ##
##############################
If ($IPSplit[0] -eq 10) #Determines Class and if IP is Private
    { $IsPrivate = $True
      $Class = "A"
    } elseif ($IPSplit[0] -eq 172 -and ( 16 -ge $IPSplit[1] -le 31))
        { $IsPrivate = $True
          $Class = "B"
            } elseif ($IPSplit[0] -eq 192 -and $IPSplit[1] -eq 168)
            { $IsPrivate = $True
              $Class = "C"}

$PC = New-Object -TypeName PSObject
$PC | Add-Member -MemberType NoteProperty -name "IPAddress" -value $IPAddr 
$PC | Add-Member -MemberType NoteProperty -name "SubnetMask" -value $CIDR
$PC | Add-Member -MemberType NoteProperty -name "Netmask" -value $SubnetMask
$PC | Add-Member -MemberType NoteProperty -name  "FirstUsableIP" -value $Gateway
$PC | Add-Member -MemberType NoteProperty -name "LastUsableIP" $FinalIP
$PC | Add-Member -MemberType NoteProperty -name "BroadcastIP"  -value $BroadIP
$PC | Add-Member -MemberType NoteProperty -name "IPRange" -value ("$Gateway - $FinalIP")
$PC | Add-Member -MemberType NoteProperty -name "UsableIPs" -value $UsableIP
$PC | Add-Member -MemberType NoteProperty -name "IsPrivate" -value $IsPrivate
$PC | Add-Member -MemberType NoteProperty -name "Class" -value $Class

$PC 
} #End of Function
Get-IPInfo -IPAddress 192.168.2.5 -CIDR 29

#New-Alias GIP Get-IPInfo

#Export-ModuleMember -Function Get-IPInfo
#Export-ModuleMember -alias GIP

[string]$var = "255.255.242.0"
$array = $var.Split(".")
[int]$value = "0"
foreach ($i in $array) {
    if ($i -eq "0") {
       $value + 0
       }
    else { 
    for ($b = 0; $a -le $i; $b++)
        {
        $a = [math]::Pow(2,$b)
        }
    $value + $b
    }

}


$regex = "\d{1,3}"
$isolated = $var.Split(".") | Select-String -Pattern $regex -Exclude "255","0"
$isolated
if ($var.Contains("255")) {
    (($array | Select-String "255").count) * 8 
    }

for ($i = 8; $i -ge 0; $i--)
    {[math]::Pow(2,$i)
    }