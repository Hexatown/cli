Write-Host "Installing  " -ForegroundColor Green

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


Copy-Item "$PSScriptRoot\hexatown.ps1" -Destination $destdir
Copy-Item "$PSScriptRoot\hexatown.cmd" -Destination $destdir
Copy-Item "$PSScriptRoot\package.json" -Destination $destdir



