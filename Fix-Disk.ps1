function fix-disk { 
    param ([switch]$sql)
    BEGIN {}
    PROCESS{
            if ($SQL) {
                onlinedisks -SQL $true
                } else {
                onlinedisks -SQL $false}
            }#end process
    END {}
    }
function onlinedisks {
    param ($SQL) 
        $disks = Get-Disk | where OperationalStatus -eq "Offline"
        $disks | % {Set-disk -number $_.Number -IsOffline $false}
        if ($SQL) { 
            $allocation = "64KB" } else {
            $allocation = "4096" } 
        foreach ($i in $disks) {
            Initialize-Disk -Number $i.Number -PartitionStyle GPT -PassThru | `
            New-Partition  -UseMaximumSize -AssignDriveLetter 
            $letter = (Get-Partition ($i.Number)).DriveLetter
            Format-Volume -DriveLetter $letter[1] -FileSystem NTFS -Confirm:$false -NewFileSystemLabel ($letter[1] + "_Drive") -AllocationUnitSize $allocation
                  } #End Foreach Loop
    } #End Function
                     
 Export-ModuleMember -Function Fix-Disk


