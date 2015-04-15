$number = Read-Host Enter a number #Prompts to enter the IP Address
[int]$mask = Read-Host Enter a netmask #Prompts to enter the subnet (e.g. /14, /22)
[int]$sub = 8 #Sets one of our constant variables
$remainder = $null #establishes a variable and sets its value to $null for now
$final = [math]::DivRem($mask,$sub,[ref]$remainder) #Determines the amou
$function = [math]::Pow(2,(8 - $remainder)) #determines the inverse subnet mask 
([math]::floor(($number / $function))) * $function + 1 #determines the subnet mask
Write-Output "$final, $remainder, $function" 