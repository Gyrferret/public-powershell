function Join-Files {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
        HelpMessage="Enter the Directory for  the Files to Join"
        )]
        [string]$Directory,
        [Parameter(
        HelpMessage="Enter the destination file with which to write to."
        )]
        [string]$Destination,
        [Parameter(
        HelpMessage="Enter String to Search Files for"
        #ParameterSetName="Content"
        )]
        [string]$Content,
        [Parameter(
        ParameterSetName="IPAddresses"
        )]
        [switch]$IPAddresses
        ) # End Param
BEGIN{ #Begin BEGIN
} #End BEGIN

PROCESS{ #Begin Process
    if ($IPAddresses) { #Logic if IPAddresses Switch is present
        JoinWIP -Directory $Directory -Destination $Destination -IPAddresses $true
        }
    elseif ($Content) { #Logic if Content to search for is present
        JoinWContent -Directory $Directory -Destination $Destination -Content $Content
        }
    else { # Logic for simply concatinating files
        JoinFiles -Directory $Directory -Destination $Destination
        }
} #End Process
END{}
} # End Join-Files Function
Function JoinFiles { #Begin JoinFiles Function
    Param(
        $Directory,
        $Destination)
    $path = Get-ChildItem $Directory #Creates a variable with all the Files in the requested Directory
    $memstream = New-Object System.IO.MemoryStream #creates a stream present in memory which will be written to
    $Writer = New-Object System.IO.StreamWriter -ArgumentList $memstream #establishes a stream-writer to write to the memory stream created earlier
    Foreach ($i in $path.FullName) { # this loop will write the contents of all files in the directory to a memory stream which will be used later depending on flags used.
        $stream = New-Object System.IO.StreamReader -ArgumentList $i #Creates a file stream reader that will read content from the specified file
        $Writer.Write($stream.ReadToEnd()) #writes the content of the file stream to the memory stream
        $stream.Close() # closes the file  stream
        }
    $Writer.Flush() # flushes the content of the memory stream writer
    $memstream.Position = 0 # Resets the stream "position" to the beginning, since it will be at the end position since the memory stream writer was writing to it.
    $memreader = New-Object System.IO.StreamReader -ArgumentList $memstream # Creates a Memory Stream Reader to read the content of the memory stream created from the files we specified.
    $memwriter = New-Object System.IO.StreamWriter  $Destination
    $memwriter.Write($memreader.ReadToEnd())
    $memreader.Close()
    $memwriter.Close()
}
function JoinWContent {
    Param(
        $Directory,
        $Destination,
        $Content)
    $path = Get-ChildItem $Directory #Creates a variable with all the Files in the requested Directory
    $memstream = New-Object System.IO.MemoryStream #creates a stream present in memory which will be written to
    $Writer = New-Object System.IO.StreamWriter -ArgumentList $memstream #establishes a stream-writer to write to the memory stream created earlier
    Foreach ($i in $path.FullName) { # this loop will write the contents of all files in the directory to a memory stream which will be used later depending on flags used.
        $stream = New-Object System.IO.StreamReader -ArgumentList $i #Creates a file stream reader that will read content from the specified file
        $Writer.Write($stream.ReadToEnd()) #writes the content of the file stream to the memory stream
        $stream.Close() # closes the file  stream
        }
    $Writer.Flush() # flushes the content of the memory stream writer
    $memstream.Position = 0 # Resets the stream "position" to the beginning, since it will be at the end position since the memory stream writer was writing to it.
    $memreader = New-Object System.IO.StreamReader -ArgumentList $memstream # Creates a Memory Stream Reader to read the content of the memory stream created from the files we specified.
    $memwriter = New-Object System.IO.StreamWriter  $Destination
        Do {
            $var = $memreader.ReadLine()
        if ($var -match $content){
            $memwriter.WriteLine($var)
            }
        } while ($memreader.ReadLine() -ne $null)
     $memreader.Close()
     $memwriter.Close()
} #End JoinWContent Function
Function JoinWIP {
    Param(
        $Directory,
        $Destination)
    $path = Get-ChildItem $Directory #Creates a variable with all the Files in the requested Directory
    $regex = "\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b"
    $memstream = New-Object System.IO.MemoryStream #creates a stream present in memory which will be written to
    $Writer = New-Object System.IO.StreamWriter -ArgumentList $memstream #establishes a stream-writer to write to the memory stream created earlier
    Foreach ($i in $path.FullName) { # this loop will write the contents of all files in the directory to a memory stream which will be used later depending on flags used.
        $stream = New-Object System.IO.StreamReader -ArgumentList $i #Creates a file stream reader that will read content from the specified file
        Do {
            $var = [regex]::Matches($stream.Readline(), $regex).value
            if ($var) {
                
            $writer.WriteLine($var)
            }
        } while ($stream.ReadLine() -ne $null)
        #writes the content of the file stream to the memory stream
        $stream.Close() # closes the file  stream
        }
    $Writer.Flush()
    $memstream.Position = 0
    $memreader = New-Object System.IO.StreamReader $memstream
    $array = DO {
    $memreader.Readline() }
    while ($memreader.ReadLine() -ne $null)
    $memreader.Close()
    $Writer = New-Object System.IO.StreamWriter -ArgumentList $destination
    Foreach ($i in ($array | sort -Unique)) {
        $Writer.WriteLine($i)
            }
    $Writer.Close()
} # End JoinWIP Function
Export-ModuleMember Join-Files