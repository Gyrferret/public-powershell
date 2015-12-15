Function Split-File {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$file,
        [Parameter(Mandatory=$true,
        HelpMessage="Enter the destination path for split files"
        )]
        [string]$path,
        $quantity = 3MB) # End Param

BEGIN{ #Begin BEGIN
    if(!(Test-Path $file)) {
        Write-Error -Message "Specified File does not Exist!"
        Exit
    if(!(Test-Path $path)) {
        Write-Warning -Message "Specified destination path does not exist. Creating at File location"
        $path = (Get-ChildItem $file).Directory
        }
    }
} #End BEGIN        
PROCESS{ # Begin PROCESS
    $lines = 0
    $count = New-Object "System.IO.StreamReader" -ArgumentList $File
        while ($count.ReadLine() -ne  $null)
        {$lines++
            }
    $ReadLines =[math]::Floor($lines/$quantity)
    $ReadLines
    $count.Close()
    $FinalPaths = @()
    for($i = 1; $i -le $quantity; $i++) {
        $NewFile = MakeNewFile -File $File -path $path -counter $i
        $FinalPaths += $NewFile.Destinationfile
        }
    SplitFile -file $file -path $FinalPaths -lines $ReadLines
    } # End PROCESS
END{ #Begin END
    } #End END
} #End Function         
Function MakeNewFile{
    param(
        $File,
        $path,
        [int]$counter)
    $name = (Get-ChildItem $File).BaseName
    $FinalPath = Join-path -path $path -childpath ($name + "_$counter" + ".txt")
    New-Item -Path $FinalPath -ItemType File
    $counter ++
    New-Object -TypeName PSObject -ArgumentList @{"DestinationFile"=$FinalPath}
    }
Function SplitFile {
    param(
        $file,
        $path,
        $lines)
    $stream = New-Object "System.IO.StreamReader" -ArgumentList $File
    Foreach( $DestinationFile in $path) {       
            $i = 0
        $test=    if (!($DestinationFile -eq $path[-1])) {    
            while($i -lt $lines) {
            $stream.ReadLine()
            $i++
            }
            } else {
            $stream.Readtoend()
            } 
        $test > $DestinationFile
        }
    $stream.close()
    } # End SplitFile Function

Export-ModuleMember Split-File