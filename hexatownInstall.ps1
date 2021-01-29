Write-Host "Installing Hexatown " -ForegroundColor Green

$environmentPath = ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)) 

$appdir = $environmentPath + "\hexatown.com"
$destdir = $environmentPath + "\hexatown.com\.hexatown"



if (!(Test-Path $appdir)) {
    New-Item -ItemType Directory -Force -Path $appdir | Out-Null
}

if (!(Test-Path $destdir)) {
    New-Item -ItemType Directory -Force -Path $destdir | Out-Null
}

$path = [Environment]::GetEnvironmentVariable("path","User")

if (!$path.Contains($destdir)){
    [Environment]::SetEnvironmentVariable("path","$path; $destdir","User")
}

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force:$true

Copy-Item "$PSScriptRoot\hexatown.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\h.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\x.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\t.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\hx.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\xt.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\hxt.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\hexatown.cmd" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\package.json" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\src" -Destination $destdir -Force -Recurse

Push-Location $destdir
Write-Host "****************************************************************" -ForegroundColor White -BackgroundColor Black
Write-Host " Running DEMO                                                   " -ForegroundColor White -BackgroundColor Black
Write-Host "****************************************************************" -ForegroundColor White -BackgroundColor Black
Write-Host " "                                                              -ForegroundColor White -BackgroundColor Black
Write-Host " If this is the first time you install Hexatown, you will be    " -ForegroundColor Yellow -BackgroundColor Black
Write-Host " prompted to consent to Hexatown getting access to your account " -ForegroundColor Yellow -BackgroundColor Black
Write-Host " the code that you need to use for sign in is on the clipboard  " -ForegroundColor Yellow -BackgroundColor Black
Write-Host " "                                                              -ForegroundColor White -BackgroundColor Black
Write-Host "**************************************************************" -ForegroundColor White -BackgroundColor Black
Write-Host "Press Enter to continue ..." -ForegroundColor Green
read-host 
. "./src/jobs/powershell/myteams.ps1"

Write-Host "Press Enter to close ..." -ForegroundColor Green
read-host 