$user = "user" #User's Username
$password = "password" #User's Password
$clientID = "clientid" #User's Application Client ID
$clientSecret = "clientsecret" #User's Application Secret


$credentials = @{ #builds body for submission
    username = $user #
    grant_type = "password" #Use "password" since this is a personal script
    password = $password 
    }


$token = Invoke-RestMethod -Method Post -Uri "https://www.reddit.com/api/v1/access_token" -Body $credentials -ContentType 'application/x-www-form-urlencoded' -Credential $clientID #Retrieves token

$header = @{
    authorization = $token.token_type + " " + $token.access_token #authorization header to be used for all API calls
    }
$Agent = "Windows Powershell 5.0" #Agent String

$Account = Invoke-RestMethod -Uri https://oauth.reddit.com/api/v1/me  -Headers $header -UserAgent $Agent #retrieves account information


