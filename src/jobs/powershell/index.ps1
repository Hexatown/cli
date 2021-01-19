#region Init
. "$PSScriptRoot\.hexatown.com.ps1"
$userAPI = @{
me =   @{
    url = "https://graph.microsoft.com/v1.0/me"
}
teams = @{
    url = "https://graph.microsoft.com/v1.0/me/joinedTeams"
}
    
}

#endregion
$me = Me 

GET $userAPI.me
 

Done $me