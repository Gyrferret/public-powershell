$user = "Gyrferret"
$password = "password" 
$clientID = "clientID"
$clientSecret = "clientsecret"

$jsonc = $credentials 
$jsonh = $header | ConvertTo-Json

($clientID + ":" + $clientSecret)

$token = Invoke-RestMethod -Method Post -Uri "https://www.reddit.com/api/v1/access_token" -Body $jsonc -ContentType 'application/x-www-form-urlencoded' -Credential $clientID

$header = @{ 
    authorization = $token.token_type + " " + $token.access_token
    }

$header
Invoke-RestMethod -uri "https://oauth.reddit.com/api/v1/me" -Headers $header -UserAgent "Powershell Test"