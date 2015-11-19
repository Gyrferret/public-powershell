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
    if ($catch)
        { Foreach ($IPAddress in $IPAddress) { #function to run if CIDR notation present
            GetIPInfo -IPAddr "$IPAddress" -CIDR "$CIDR"
            } #end function if CIDR notation present
        } else {
         Foreach ($IPAddress in $IPAddress) { #function to run if netmask present
            $CIDRN = GETCIDR -subnet $NetMask 
            $Ipinfo = GetNetMask -IPAddr $IPAddress -CIDR $CIDRN.CIDR
            $range = GetRange -subnetmask $IpInfo.netmask -GateIP $IpInfo.GatewayIP -InvSub $IpInfo.InverseSubnet
            $class = GetIPClass -IPAddr $IPAddress
$PC = New-Object -TypeName PSObject
$PC | Add-Member -MemberType NoteProperty -name "GatewayIP" -Value $Ipinfo.GatewayIP
$PC | Add-Member -MemberType NoteProperty -name "IPAddress" -value $Ipinfo.IPAddress 
$PC | Add-Member -MemberType NoteProperty -name "CIDR" -value $Ipinfo.CIDR
$PC | Add-Member -MemberType NoteProperty -name "Netmask" -value $ipinfo.netmask
$PC | Add-Member -MemberType NoteProperty -name "UsableIPs" -value $range.UsableIP
$PC | Add-Member -MemberType NoteProperty -name "FirstUsableIP" -value $range.Gateway
$PC | Add-Member -MemberType NoteProperty -name "LastUsableIP" $range.FinalIP
$PC | Add-Member -MemberType NoteProperty -name "BroadcastIP"  -value $range.BroadIP
$PC | Add-Member -MemberType NoteProperty -name "IPRange" -value ($range.Gateway - $range.FinalIP)
$PC | Add-Member -MemberType NoteProperty -name "IsPrivate" -value $class.IsPrivate
$PC | Add-Member -MemberType NoteProperty -name "Class" -value $class.Class
$PC
            } #end function if netmask presnt
        } #End Statement
    } #End of PROCESS

END{} #End of End
}

function GETCIDR { #function to convert netmask to CIDR notation. 
    param([string]$subnet)
        $a = $null #initializes the $a variable for future use
        $array = $subnet.Split(".") 
        $fullbytes = ($array | Select-String "255").count
        $test = $array[$fullbytes]
        for ($i = 8; $a -lt $test; $i--) #determines number of similar bits
            {$a = (256 - [math]::Pow(2,$i))}
        $CIDRSub = (7 - $i)
        if ($array.Contains("255")) { #assembles the CIDR notation
            $toCIDR = ($fullbytes * 8) + ($CIDRSub)
        } else {
            $toCIDR = $CIDRSub
        }
    $pc = New-Object -TypeName PSObject
    $pc | Add-Member -Membertype NoteProperty -Name CIDR -Value $toCidr
$pc
}

function GetNetMask {
param(
    [String]$IPAddr,
    [int32]$CIDR)
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
if ($SimOctets -lt 3) #if condition to set the final octet as .1 if netmask less than a /24
     {
        $SubnetMask = (([string]"255.") * $SimOctets)+ $subnet + (([String]".0")*(3 - $SimOctets)) #creates the gateway of any subnets less than a /24
    } else { 
        $Subnetmask = (([string]"255.") * $SimOctets)+ $subnet #creates the gateway of any subnets greater= than or equal to a /24
        }

$PC = New-Object -TypeName PSObject
$PC | Add-Member -MemberType NoteProperty -name "GatewayIP" -Value $GateIP
$PC | Add-Member -MemberType NoteProperty -Name "InveseSubnet" -Value $InvSub
$PC | Add-Member -MemberType NoteProperty -name "IPAddress" -value $IPAddr 
$PC | Add-Member -MemberType NoteProperty -name "CIDR" -value $CIDR
$PC | Add-Member -MemberType NoteProperty -name "Netmask" -value $SubnetMask
$PC | Add-Member -MemberType NoteProperty -name "UsableIPs" -value $UsableIP
$PC
} #end GetNetMask Function

Function GetRange {
    Param(
    [string]$SubnetMask,
    [int]$GateIP,
    [int]$InvSub)
    $SimIP = $null
    $array = $SubnetMask.Split(".") 
    $SimOctets = ($array | Select-String "255").count
    For ( $b = ($SimOctets - $SimOctets); $b -lt $SimOctets; $b++)
        { $SimIP += $array[$b] + "." }
    if ($SimOctets -lt 3) {
        $FinalIP = $SimIP + [String]($GateIP + $InvSub - 1) + (([String]".0")*(2 - $SimOctets)) + ([String]".254")
        $Gateway = $SimIP + [String]$GateIP + (([String]".0")*(2 - $SimOctets)) + ([String]".1")
        $BroadIP = $SimIP + [String]($GateIP + $InvSub - 1) + (([String]".0")*(2 - $SimOctets)) + ([String]".255")
    } else {
        $Gateway = $SimIP + $GateIP
        $FinalIP = $SimIP + ($GateIP + $InvSub - 3)
        $BroadIP = $SimIP + ($GateIP + $InvSub - 2)
    }
    $PC = New-Object -TypeName PSObject
    $PC | Add-Member -MemberType NoteProperty -name  "FirstUsableIP" -value $Gateway
    $PC | Add-Member -MemberType NoteProperty -name "LastUsableIP" $FinalIP
    $PC | Add-Member -MemberType NoteProperty -name "BroadcastIP"  -value $BroadIP
    $PC | Add-Member -MemberType NoteProperty -name "IPRange" -value ("$Gateway - $FinalIP")
$PC
} #end GetRange Function.

Function GetIPClass {
    param([Parameter(ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True,
                    Mandatory=$True)]
            [Alias('IP')]
        [string]$IPAddr
    )
$IPSplit = $IPAddr.split(".")
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
    $PC | Add-Member -MemberType NoteProperty -name "IsPrivate" -value $IsPrivate
    $PC | Add-Member -MemberType NoteProperty -name "Class" -value $Class
$PC
} #end GetIPClass functon

$PC 
 #End of Function
Get-IPInfo -IPAddress 192.168.2.5 -NetMask 255.255.255.128


#New-Alias GIP Get-IPInfo

#Export-ModuleMember -Function Get-IPInfo
#Export-ModuleMember -alias GIP
