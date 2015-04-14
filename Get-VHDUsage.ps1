function Get-VHDUsage {
param (
    [Parameter(ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True)]
            [Alias('host')]
            [STRING[]]$computername,
            [String]$path = 'C:\VHDResults.txt', #specifies the default locations of the usage file
            [String]$logfile = 'C:\VHDContactErrors.txt'#Specifies the default locaiton of the error file
        )
BEGIN{}
PROCESS{
    foreach ($computernamed in $computername) { #runs the VHD function on every computer provided within the input
    GetVMSize -computername $computernamed -logfile $logfile -path $path #passes along the files if provided
        }
    }
END{$usedLogParameter = $false #Sets the parameter to default to false
        if ($PSBoundParameters.ContainsKey('logfile')) {
         $usedLogParameter = $true} #If parameter was used, sets variable to true
    $usedPathParameter = $false #Sets the parameter to default to false
        if ($PSBoundParameters.ContainsKey('path')) {
         $usedPathParameter = $true} #If parameter was used, sets variable to true
    if ($usedPathParameter) {
        Write-Output 'VM Usage Logs can be found at C:\VHDResults.txt' #Writes the default location of the error log if no location was given
        } else { 
            Write-Output "VM Usage Logs can be found at $path" #Writes the location of the log if one was provided
            }
    if ($usedLogParameter) {
        Write-Output 'Error Logs can be found at C:\VHDContactErrors.txt' #Writes the default location of the Usage Log if not location was given
        } else { 
            Write-Output "VM Usage Logs can be found at $Logfile" #writes the location of the usage log if one was provided
            }
    }
}
function GetVMSize {
    param($computername = 'localhost', $logfile = 'C:\VHDContactErrors.txt', $path = 'C:\VHDResults.txt') #specifies the default variable settings
    del $logfile -ea SilentlyContinue #Deletes Logs if they are alreadypresent
    del $path -ea SilentlyContinue
    try {
            $VM = Get-VM -ComputerName $computername #Grabs all the Virtual Machines on the enumerated server
            $VMD = (Get-VHD $VM.ID -ea Stop -ev GVHDError| where vhdtype -EQ * | where vhdformat -eq *) #Looks for VHDs that are 1.) Dynamic and 2.) VHDX
        } catch { 
            $GVHDError | Out-File $logfile -Append #Writes any errors to the logfile
            }
        
    ForEach ($VHD in $VMD) #Runs the command on each VHD discovered above
        {
         
        try {
            $VHDU = $VHD | select  @{l='DiskUsed';e={$_.Filesize / $_.Size * 100 -as [int]}} -ea Stop -ev ErrorDescrip #Calculates the usage of the VHDX
           
            $obj = New-Object -TypeName PSObject #Creates a new member
            $obj | Add-Member -MemberType NoteProperty -Name 'Host' -Value ($VHD.ComputerName) 
            $obj | Add-Member -MemberType NoteProperty -Name 'Used %' -Value ($VHDU.DiskUsed)
            $obj | Add-Member -MemberType NoteProperty -Name 'VM Path' -Value ($vhd.Path)

            $obj | select -Property 'Host','Used %','VM Path' | ft -AutoSize |  Out-file  $path -Append #Writes all data to the given results path 
        } catch {$VHD.DiskIdentifier | Out-File $logfile -Append
                $ErrorDescrip | Out-File $logfile -Append} 

    }
}

New-Alias gvmu Get-VHDUsage

Export-ModuleMember -Function Get-VMUsage
Export-ModuleMember -alias gvmu