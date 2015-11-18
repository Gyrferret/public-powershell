function Get-Password {
param( 
[int] $length = 12,
[int] $quantity =1,
[switch] $complex,
[switch] $nonalphanumeric
)
BEGIN{
    #Based upon the switch that is selected ($complex, $nonalphanumeric), selects the appropriate
    #character base  to utilize for password generation.
    If ($nonalphanumeric) {
        [string]$cBase = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~!@#$%^&*_-+=`|\)(}{][:;><,.?`'`"" 
    } elseif ($complex) {
        [string]$cBase = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~!@#$%^&*" 
     } else {
     [string]$cBase = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        }
    } #End Begin Statement
PROCESS{
    $PArray = @() #initializes empty password array
    for ($i = $0; $i -lt $quantity; $i++) { #Runs the password generation the amount of times requested in $quantity
        $Password = GeneratePassword -length $length -cBase $cBase #passes the character base and requested length to the GeneratePassword function
        $PArray += $Password #adds the returned password to the password array
        }
    $PArray #outputs the array to the host
    } #End Process Statement
END{ #disposes of the RNGCryptoServiceProvider and leaves it in an "usuable state"
    $crypto = New-Object System.Security.Cryptography.RNGCryptoServiceProvider 
    $crypto.Dispose()   
    } #End End Statment
} #End Get-Password Function
Function GeneratePassword{
    param(
    [int]$length,
    [string]$cBase
    )
    $bytes = new-object "System.Byte[]" $length #creates a new Byte object of a length that is of the requested password length.
    $crypto = new-object System.Security.Cryptography.RNGCryptoServiceProvider
    $crypto.GetNonZeroBytes($bytes) #fills the $bytes object with an array of random bytes
    $password = "" #creates an empty string
        for( $i=0; $i -lt $length; $i++ ) #iterates the random function over the amount requested.
        {
        $password += $cBase[$bytes[$i] % $cBase.Length] 
        #selects the Character from the Character Base string based on the Remainder value when dividing
        #the random number by the total length of the character base string, then adds the selected character
        #to the new password string.
        }                                                
    $password
} #End of GeneratePassword Function.
Export-ModuleMember Get-Password
New-Alias gpwd
Export-Alias gpwd