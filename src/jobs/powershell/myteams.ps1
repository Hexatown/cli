. "$PSScriptRoot\.hexatown.com.ps1"                                         # Load the Hexatown framework
$hexatown = Init $MyInvocation  $false $true                                # Stop the framework
$myTeams = LIST $hexatown $userAPI.teams                                    # Read the Teams of the delegate user
foreach ($team in $myTeams | Sort-Object -Property displayName  )           # Sort teams by display name and run the code block
{                                                                           # Start code block
    Write-Host $team.displayName                                            # Write the value of a team to the host
}                                                                           # End code block
Done $hexatown                                                              # Stop the framework       