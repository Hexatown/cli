param (
[Parameter(Mandatory=$true)]
$url #="https://hexatown.blob.core.windows.net/powerbricks/room-manager.0.0.1.zip?sp=r&st=2021-03-29T10:56:43Z&se=2021-03-29T18:56:43Z&spr=https&sv=2020-02-10&sr=b&sig=Sfo1R95EfaPva2wMW3OFdLURg5xjMxyfdQ9xJS6Jj4w%3D" 
)
function Get-Downloader {
param (
  [string]$url
 )

  $downloader = new-object System.Net.WebClient

  $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
  if ($defaultCreds -ne $null) {
    $downloader.Credentials = $defaultCreds
  }

  $ignoreProxy = $env:hexatownIgnoreProxy
  if ($ignoreProxy -ne $null -and $ignoreProxy -eq 'true') {
    Write-Debug "Explicitly bypassing proxy due to user environment variable"
    $downloader.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
  } else {
    # check if a proxy is required
    $explicitProxy = $env:hexatownProxyLocation
    $explicitProxyUser = $env:hexatownProxyUser
    $explicitProxyPassword = $env:hexatownProxyPassword
    if ($explicitProxy -ne $null -and $explicitProxy -ne '') {
      # explicit proxy
      $proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
      if ($explicitProxyPassword -ne $null -and $explicitProxyPassword -ne '') {
        $passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
        $proxy.Credentials = New-Object System.Management.Automation.PSCredential ($explicitProxyUser, $passwd)
      }

      Write-Debug "Using explicit proxy server '$explicitProxy'."
      $downloader.Proxy = $proxy

    } elseif (!$downloader.Proxy.IsBypassed($url)) {
      # system proxy (pass through)
      $creds = $defaultCreds
      if ($creds -eq $null) {
        Write-Debug "Default credentials were null. Attempting backup method"
        $cred = get-credential
        $creds = $cred.GetNetworkCredential();
      }

      $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
      Write-Debug "Using system proxy server '$proxyaddress'."
      $proxy = New-Object System.Net.WebProxy($proxyaddress)
      $proxy.Credentials = $creds
      $downloader.Proxy = $proxy
    }
  }

  return $downloader
}


function Download-File {
param (
  [string]$url,
  [string]$file
 )
  #Write-Output "Downloading $url to $file"
  $downloader = Get-Downloader $url

  $downloader.DownloadFile($url, $file)
}



$tempDir = join-path ( [System.IO.Path]::GetTempPath()) "hexatown"
if (![System.IO.Directory]::Exists($tempDir)) {[void][System.IO.Directory]::CreateDirectory($tempDir)}
$file = Join-Path $tempDir "hexatown.zip"


# Download the Hexatown package
Write-Output "Downloading package from $url."
Download-File $url $file

# unzip the package
Write-Output "Extracting $file to $tempDir..."
Expand-Archive -Path "$file" -DestinationPath "$tempDir/install" -Force

if (!(Test-path "$tempDir/install/powerbrick.json")){
    throw "Missing manifest $("$tempDir/install/powerbrick.json")" 
}


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
Copy-Item "$PSScriptRoot\hexa.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\hexatree.ps1" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\hexatown.cmd" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\package.json" -Destination $destdir -Force
Copy-Item "$PSScriptRoot\src" -Destination $destdir -Force -Recurse
Copy-Item "$PSScriptRoot\modules" -Destination $destdir -Force -Recurse
Copy-Item "$PSScriptRoot\img" -Destination $destdir -Force -Recurse

# & "$destdir\src\pages\file-explorer.ps1"
write-host "Hexatown CLI installed" -ForegroundColor Green
exit

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


