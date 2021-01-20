. "$PSScriptRoot\.hexatown.com.ps1"                # Load the Hexatown framework
$hexatown = Start-Hexatown  $myInvocation          # Start the framework
$myTeams = List $hexatown my teams by displayName  # Read the Teams of the delegate user sorted by name
foreach ($team in $myTeams )                       # Repeat code for each team
{                                                  # Start code block
    Write-Host $team.displayName                   # Write the value of a team to the host
}                                                  # End code block
Stop-Hexatown $hexatown                            # Stop the framework       