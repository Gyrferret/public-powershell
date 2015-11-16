function Get-Password {
param( 
[int] $length = 12,
[switch] $complex,
[switch] $nonalphanumeric
)
If ($nonalphanumeric) 
    {[string]$cBase = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~!@#$%^&*_-+=`|\)(}{][:;><,.?`'`"" }
     elseif ($complex) {
     [string]$cBase = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~!@#$%^&*"
     } else {
     [string]$cBase = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    }
$bytes = new-object "System.Byte[]" $length
$crypto = new-object System.Security.Cryptography.RNGCryptoServiceProvider
$crypto.GetNonZeroBytes($bytes)
$password = ""
for( $i=0; $i -lt $length; $i++ )
{
$password += $cBase[$bytes[$i] % $cBase.Length]
}
$password
}