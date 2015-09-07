$subnet = "255.255.0.192"
$subsplit = $subnet.Split(".") | where {$_ -ne "255" -and $_ -ne "0"}
$octets = ((($subnet.Split(".") | where {$_ -eq "255"}).Count) * 8)
Write-Output "Octets equals $octets"
Write-Output "Subsplit equals $subsplit"
if (!($subsplit -eq $null)) {
    for ($i = 1; $b -ne $subsplit; $i++)
        { $b = 256 - [math]::Pow(2,$i)
         }
    } else {
        $i = 9}
Write-output "'$i' = $i"
$netsize = $octets + (9 - $i)
Write-Output "netsize equals $netsize"

Write-Output "This is a /$netsize Subnet!"


Clear-Variable i,subsplit,netsize

$subnet = "255.255.255.192"