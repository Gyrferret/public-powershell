

[string]$pref = Read-Host "Would you like to speak to the cat?"
if ($pref -contains "y")
    {Write-Output "Speak to the cat"
    $voice = Read-Host "What should the cat say?"
    talk -words $voice
    } else{
    $pref2 = Read-Host "Would you rather the cat speak to you?"
    
    if ($pref2 -contains "y")
        {   specs
            speak
        } 
    $perf3 = Read-Host "Would you rather the cat read to you?"
    if ($perf3 -contains "y")
        { read -path $profile.ToSring()
        } else {

            "Cat too good for you anyway"
            specs
            }

    }

$cat = New-Object cat
Function specs {
    $cat.age = (get-random -Minimum 1 -Maximum 20)
    $cat.color = ([color] (get-random -Minimum 1 -Maximum 4))
    $cat.type = ([type] (Get-Random -Minimum 1 -Maximum 3))
    $color = $cat.color.ToString().ToLower()
    $age = $cat.age0
    $type = $cat.type
    Write-Output "The $type $color cat happened to be $age years old"  
}

class cat { 
    [string]$name
    [int]$age
    [color]$color
    [type]$type
    static [int]$paws = 4
    speak () {[console]::WriteLine("meow")}
    repeat ($arg) {$string = "meow $arg meow"
    [console]::WriteLine($string) }
    verify ($arg,$arg2) {if ($arg -eq $arg2) {
        [console]::WriteLine("We have meow")
        } else { [console]::Writeline("We have no meow")
            }
        }
         
    }
enum color {
    Brown = 1
    Black = 2
    White = 3
    Calico = 4
    }
enum type {
    big = 1
    small = 2
    hairy = 3
    }
function talk {
    param(
        [string]$words
        )
        $cat.repeat("$words")
    }
function speak { 
    $cat.speak()
    }
function speak {
    param (
        [string]$path
        )
    $lines = New-Object System.IO.StreamReader($path)
    $ref = $lines.ReadLine()
    while ( $ref -ne $null)
        { Write-Host $ref
        $ref = $lines.ReadLine()
        }
    Write-Host "All done"
    }
