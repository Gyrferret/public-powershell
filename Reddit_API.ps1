function Get-RedditToken {
$user = "user"
$password = "password" 
$clientID = "clientID"
$clientSecret = ConvertTo-SecureString "secret" -AsPlainText -Force
$creds = New-Object -TypeName System.management.Automation.PSCredential -ArgumentList $clientID, $clientSecret 

$credentials = @{
    grant_type = "password"
    username = $user
    password = $password
    }
$env:token = Invoke-RestMethod -Method Post -Uri "https://www.reddit.com/api/v1/access_token" -Body $credentials -ContentType 'application/x-www-form-urlencoded' -Credential $creds
}
Get-RedditToken


function Get-RedditUser {
    param(
    [string]$username,
    [switch]$info
    )
    if (!($token))
        {Get-RedditToken}
        $header = @{ 
            authorization = $token.token_type + " " + $token.access_token
         }
    if ($info)
        {$accinfo = (Invoke-RestMethod -uri "https://oauth.reddit.com/user/$username/about" -Headers $header -UserAgent "Powershell Test").data
        $acccreate = (Get-Date -date 1.1.1970).AddSeconds(($accinfo.created))
        $pc = New-Object -TypeName PSObject
        $pc | Add-Member -MemberType NoteProperty -Name "Account Name" -Value ($accinfo.name)
        $pc | Add-Member -MemberType NoteProperty -Name "Link Karma" -Value ($accinfo.link_karma)
        $pc | Add-Member -MemberType NoteProperty -Name "Comment karma" -Value ($accinfo.comment_karma)
        $pc | Add-Member -MemberType NoteProperty -Name "Combined karma" -Value (($accinfo.comment_karma) + ($accinfo.link_karma))
        $pc | Add-Member -MemberType NoteProperty -Name "Account Created" -Value ($acccreate)
        $pc | Add-Member -MemberType NoteProperty -Name "Gilded" -Value ($accinfo.is_gold)
        $pc | Add-Member -MemberType NoteProperty -Name "Mod" -Value ($accinfo.is_mod)
        $pc
        }
        else {
            (Invoke-RestMethod -uri "https://oauth.reddit.com/user/$username" -Headers $header -UserAgent "Powershell Test").data.children.data
            }
}
Get-RedditUser -username Reddit_User -info