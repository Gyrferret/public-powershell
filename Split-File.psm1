Function Split-File {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$file,
        [Parameter(Mandatory=$true,
        HelpMessage="Enter the destination path for split files"
        )]
        [string]$path,
        $quantity = 5) # End Param

BEGIN{ #Begin BEGIN
    while(!(Test-Path $file -PathType Leaf)) {
        Write-Warning -Message "Specified File does not Exist or is a Directory!"
        $file = Read-Host "Please Enter a Valid File" }               
    if(!($path)) { #tests to see if path was specified at all
        Write-Warning -Message "Destination Path does not exist. Creating at File location"
        $path = (Join-Path -Path ((Get-ChildItem $file).Directory) -ChildPath ((Get-ChildItem $file).basename))
       $path = (GenerateDirectory -path $path -file $file) 
    } else { 
        $path = (GenerateDirectory -path $path -file $file)
     } #end else statement 
    
} #End BEGIN        
PROCESS{ # Begin PROCESS
    $lines = 0
    $count = New-Object "System.IO.StreamReader" -ArgumentList $File
        while ($count.ReadLine() -ne  $null)
        {$lines++
            }
    $ReadLines =[math]::Floor($lines/$quantity)
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
    if(Test-Path $FinalPath) {
        Write-Warning "Destination File Already Exists! Creating new File"
        $random = Get-Random
        $finalpath = Join-path -path $path -childpath ($name + "_$counter" +"_$random"+ ".txt")
        New-Item -Path $FinalPath -ItemType File
        } else {
        New-Item -Path $FinalPath -ItemType File
        }
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
function GenerateDirectory {
    param(
        [Parameter(Mandatory=$true)]
        [string]$path,
        [Parameter(Mandatory=$true)]
        [string]$file
        )
    if (!(Test-Path $path -PathType Container)) { #tests to see if specified path is a valid path (not file).
        Write-Warning -Message "Specified destination path does not exist. Creating at File location" #Warns user of what will happen
        $path = (Join-Path -Path ((Get-ChildItem $file).Directory) -ChildPath ((Get-ChildItem $file).basename)) #creates new path based on 
        if (Test-Path $path) { #logic for creating a new path if path already exists
                Write-Warning "Directory already Exists; Creating new Directory"
                $newpath = GenerateNewDirectory -path $path
                New-Item -path $newpath.path -ItemType Directory
                New-Object  -TypeName PSObject -ArgumentList @{"path"=$path}
        } else {
            New-Item $path -ItemType Directory
            New-Object  -TypeName PSObject -ArgumentList @{"path"=$path}
            } # end if statement
    } else {
    New-Object  -TypeName PSObject -ArgumentList @{"path"=$path}
    }
} #end GenerateDirectory Function
function GenerateNewDirectory { # creates the directory based on the first available free directory from the while loop 
    param([string]$path)
    $i = 1 # sets $i variable which will be used later to create new directory paths
    $newpath = $path #creates a new variable to test if it exists
    While (Test-Path $newpath) { #While loop will test new versions of the path until it finds one that doesn't exist 
        $newpath = "$path" + "_$i" #assembles the new path using the name of the file and the existing directory, plus an incremented number
            If (Test-Path $newpath) { #Begin if statement for testing new path
                $i++} 
        } # end while loop
    New-Object -TypeName PSObject -ArgumentList @{"path"=$newpath}
} #end GenerateNewDirectory function
Export-ModuleMember Split-File