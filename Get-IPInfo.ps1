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
         $NetMask = GetNetMask -IPAddr $IPAddress.IPAddress -CIDR $CIDR.CIDR
         $range = GetRange -IPAddr $IPAddress.IPAddress -CIDR $CIDR.CIDR
         $class = GetIPClass -IPAddr $IPAddress.IPAddress
    $PC = New-Object -TypeName PSObject
    $PC | Add-Member -MemberType NoteProperty -name "IPAddress" -value $IPAddress 
    $PC | Add-Member -MemberType NoteProperty -name "CIDR" -value $CIDR
    $PC | Add-Member -MemberType NoteProperty -name "Netmask" -value $netmask.netmask
    $PC | Add-Member -MemberType NoteProperty -name "UsableIPs" -value $range.UsableIPs
    $PC | Add-Member -MemberType NoteProperty -name "FirstUsableIP" -value $range.FirstUsableIP
    $PC | Add-Member -MemberType NoteProperty -name "LastUsableIP" $range.LastUsableIP
    $PC | Add-Member -MemberType NoteProperty -name "BroadcastIP"  -value $range.BroadcastIP
    $PC | Add-Member -MemberType NoteProperty -name "IPRange" -value ($range.FirstUsableIP - $range.LastUsableIP)
    $PC | Add-Member -MemberType NoteProperty -name "IsPrivate" -value $class.IsPrivate
    $PC | Add-Member -MemberType NoteProperty -name "Class" -value $class.Class
    $PC
            } #end function if CIDR notation present
        } else {
         Foreach ($IPAddress in $IPAddress) { #function to run if netmask present
            $CIDRN = GETCIDR -subnet $NetMask 
            $Ipinfo = GetNetMask -IPAddr $IPAddress -CIDR $CIDRN.CIDR
            $range = GetRange -IPAddr $IPAddress -CIDR $CIDRN.CIDR
            $class = GetIPClass -IPAddr $Ipinfo.IPAddress
    $PC = New-Object -TypeName PSObject
    $PC | Add-Member -MemberType NoteProperty -name "IPAddress" -value $Ipinfo.IPAddress 
    $PC | Add-Member -MemberType NoteProperty -name "CIDR" -value $Ipinfo.CIDR
    $PC | Add-Member -MemberType NoteProperty -name "Netmask" -value $ipinfo.netmask
    $PC | Add-Member -MemberType NoteProperty -name "UsableIPs" -value $range.UsableIPs
    $PC | Add-Member -MemberType NoteProperty -name "FirstUsableIP" -value $range.FirstUsableIP
    $PC | Add-Member -MemberType NoteProperty -name "LastUsableIP" $range.LastUsableIP
    $PC | Add-Member -MemberType NoteProperty -name "BroadcastIP"  -value $range.BroadcastIP
    $PC | Add-Member -MemberType NoteProperty -name "IPRange" -value ($range.FirstUsableIP - $range.LastUsableIP)
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
$IPSplit = $IPAddr.Split(".")
$SimOctets = [math]::DivRem($CIDR,8,[ref]$remainder) #Determines the amount similar octets the IP address has
$InvSub = [math]::Pow(2,(8 - $remainder)) #determines the inverse subnet mask (Old Method)
$Subnet = (256 - [math]::Pow(2,(8 - $remainder))) # Determines subnet mask (New Method)
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
$PC
} #end GetNetMask Function

Function GetRange {
    Param(
    [string]$IPAddr,
    [int]$CIDR)
    [string]$array = $null
    $iparray = $IPaddr.Split(".") 
    $simips = [math]::floor($CIDR/8) #determines how many similar octets
    $SimOctets = $iparray[$simips] #grabs the first non-similar octet based on above logic
    $range = [math]::Pow(2,(8-($CIDR % 8))) #determines the size of subnet range
    for( $i = 1; $a -lt $SimOctets; $i++) #iterates through multiples of the subnet range until it finds the range that the non-similar octect falls in
        {$a = $range * $i 
        }
    for($c = 0; $c -lt $simips; $c++) 
        {$array += ($iparray[$c] + ".") #re-assembles the IP based upon the amount of similar octects
        }
    $usable = [math]::Pow(2,(32-$cidr)) - 2 #determines the amount of usable IPs in the subnet
    if ($CIDR -lt 24 -and $CIDR -gt 8) { #logic for /8 through /24  networks
        $min = ($array + ($range * ($i -1)) + (([String]".0")*(2 - $simips)) + ".1")
        $max = ($array + (($range * ($i))-1) + (([String]".0")*(2 - $simips))+ ".254")
        $broad = ($array + (($range * ($i))-1) + (([String]".0")*(2 - $simips))+ ".255")
        $properties = @{
            FirstUsableIP=$min
            LastUsableIP=$max
            BroadcastIP=$broad
            UsableIPs=$usable
            }
   } elseif ($CIDR -gt 24) { #logic for /24 and above networks
        $min = ($array + (($range * ($i -1))+1))
        $max = ($array + ((($range * $i))-2))
        $broad = ($array + (($range * ($i))-1))
        $properties = @{
            FirstUsableIP=$min
            LastUsableIP=$max
            BroadcastIP=$broad
            UsableIPs=$usable
            }
   } else { #logic for /8 and below networks
        $min = (($range * ($i -1)) + (([String]".254")*(2 - $simips)) + ".1")
        $max = ((($range * ($i))-1) + (([String]".254")*(2 - $simips))+ ".254")
        $broad = ((($range * ($i))-1) + (([String]".254")*(2 - $simips))+ ".255")
        $properties = @{
            FirstUsableIP=$min
            LastUsableIP=$max
            BroadcastIP=$broad
            UsableIPs=$usable
            }
        }
   New-Object  -TypeName PSObject -Property $properties
            
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


#New-Alias GIP Get-IPInfo

Export-ModuleMember -Function Get-IPInfo
#Export-ModuleMember -alias GIP
