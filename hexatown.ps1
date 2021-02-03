<#
HEXATOWN CLI
------------
Copyright 2021 Niels Gregers Johansen

MIT Licensed

2021-01-14 Prepared for Alpha release
2021-01-03 Baseline

#>
# https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1 
 

function Read-Hexatown-Metadata() {
    if (!(Test-Path "$PSScriptRoot\package.json")) {
        return $null
    }
    return Get-Content -Path "$PSScriptRoot\package.json" -Raw  | ConvertFrom-Json
}

function Read-Hexatown-PowerBrickMetadata($path) {
    return Get-Content -Path "$path\package.json" -Raw  | ConvertFrom-Json
}

# PowerShell v2/3 caches the output stream. Then it throws errors due
# to the FileStream not being what is expected. Fixes "The OS handle's
# position is not what FileStream expected. Do not use a handle
# simultaneously in one FileStream and in Win32 code or another
# FileStream."
function Fix-PowerShellOutputRedirectionBug {
  $poshMajorVerion = $PSVersionTable.PSVersion.Major

  if ($poshMajorVerion -lt 4) {
    try{
      # http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/ plus comments
      $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
      $objectRef = $host.GetType().GetField("externalHostRef", $bindingFlags).GetValue($host)
      $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetProperty"
      $consoleHost = $objectRef.GetType().GetProperty("Value", $bindingFlags).GetValue($objectRef, @())
      [void] $consoleHost.GetType().GetProperty("IsStandardOutputRedirected", $bindingFlags).GetValue($consoleHost, @())
      $bindingFlags = [Reflection.BindingFlags] "Instance,NonPublic,GetField"
      $field = $consoleHost.GetType().GetField("standardOutputWriter", $bindingFlags)
      $field.SetValue($consoleHost, [Console]::Out)
      [void] $consoleHost.GetType().GetProperty("IsStandardErrorRedirected", $bindingFlags).GetValue($consoleHost, @())
      $field2 = $consoleHost.GetType().GetField("standardErrorWriter", $bindingFlags)
      $field2.SetValue($consoleHost, [Console]::Error)
    } catch {
      Write-Output "Unable to apply redirection fix."
    }
  }
}

Fix-PowerShellOutputRedirectionBug

# Attempt to set highest encryption available for SecurityProtocol.
# PowerShell will not set this by default (until maybe .NET 4.6.x). This
# will typically produce a message for PowerShell v2 (just an info
# message though)
try {
  # Set TLS 1.2 (3072) as that is the minimum required by hexatown.com.
  # Use integers because the enumeration value for TLS 1.2 won't exist
  # in .NET 4.0, even though they are addressable if .NET 4.5+ is
  # installed (.NET 4.5 is an in-place upgrade).
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
} catch {
  Write-Output 'Unable to set PowerShell to use TLS 1.2. This is required for contacting Hexatown as of 03 FEB 2020. https://hexatown.com/blog/remove-support-for-old-tls-versions. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5+ and PowerShell v3+, (2) Call [System.Net.ServicePointManager]::SecurityProtocol = 3072; in PowerShell prior to attempting installation, (3) specify internal Hexatown package location (set $env:hexatownDownloadUrl prior to install or host the package internally), (4) use the Download + PowerShell method of install. See https://hexatown.com/docs/installation for all install options.'
}

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

function Download-String {
param (
  [string]$url
 )
  $downloader = Get-Downloader $url

  return $downloader.DownloadString($url)
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

#$url = "https://github.com/Hexatown/cli/raw/main/hexatown.zip"

# Download the Hexatown package
#Write-Output "Getting Hexatown from $url."


function Show-Hexatown-CLIVersion() {

    $metadata = Read-Hexatown-Metadata
    Write-Host "version $($metadata.version)" -ForegroundColor:DarkGray
}

function Show-Hexatown-Header() {

    Write-Host "         "  -ForegroundColor:Yellow  -NoNewline 
    Write-Host "     "  -ForegroundColor:Green -NoNewline  -BackgroundColor DarkGreen
    Write-Host " "  -ForegroundColor:Yellow -NoNewline -BackgroundColor DarkGreen
    Write-Host "         "  -ForegroundColor:Green -NoNewline  -BackgroundColor DarkGreen
    Write-Host "        "  -ForegroundColor:Yellow
     
    Write-Host "HEXATOWN "  -ForegroundColor:Yellow  -NoNewline 
    Write-Host " Power"  -ForegroundColor:Green -NoNewline  -BackgroundColor DarkGreen
    Write-Host "⚙️"  -ForegroundColor:Yellow -NoNewline -BackgroundColor DarkGreen
    Write-Host "Bricks "  -ForegroundColor:Green -NoNewline  -BackgroundColor DarkGreen
    Write-Host " Manager"  -ForegroundColor:Yellow

    Write-Host "         "  -ForegroundColor:Yellow  -NoNewline 
    Write-Host "     "  -ForegroundColor:Green -NoNewline  -BackgroundColor DarkGreen
    Write-Host " "  -ForegroundColor:Yellow -NoNewline -BackgroundColor DarkGreen
    Write-Host "         "  -ForegroundColor:Green -NoNewline  -BackgroundColor DarkGreen
    Write-Host "        "  -ForegroundColor:Yellow

}
function Write-PowerBrick-HelpForPowerBrick(){
                write-host "Options for hexatown powerbrick"
                Write-Host " "
               # write-host "Support navigation on the developer machine between different instances of Power⚙️Bricks"# -ForegroundColor Black -BackgroundColor White

                Write-Host "hexatown powerbrick <task> [option]   "  # -NoNewline  -ForegroundColor Green
                write-host "Support navigation on the developer machine between different instances of Power⚙️Bricks"# -ForegroundColor Black -BackgroundColor White
                Write-Host " "            
                Write-Host "hexatown powerbrick register <alias>  "  -NoNewline  -ForegroundColor Green
                Write-Host "Register the current Power⚙️Brick with an optional alias"

                Write-Host "hexatown powerbrick list              "  -NoNewline  -ForegroundColor Green
                Write-Host "List Power⚙️Bricks locally registered"

                Write-Host "hexatown powerbrick go <name/alias>   "  -NoNewline  -ForegroundColor Green
                Write-Host "Change directory to the current Power⚙️Brick based on name or alias"
}

function ShowHelp($forArgument) {

    #Write-Host "Help" 
    Show-Hexatown-Header
    Show-Hexatown-CLIVersion

    if ($null -eq $forArgument) {

        Write-Host "General help" 
        
        Write-Host "hexatown go <destination> [instance]           "  -NoNewline  -ForegroundColor Green
        Write-Host "Navigate to <destination> in optional instance "
        Write-Host "hexatown init <destination>                    "  -NoNewline  -ForegroundColor Green
        Write-Host "Create a project file "
        Write-Host "hexatown env                                   "  -NoNewline  -ForegroundColor Green
        Write-Host "Change location to the path of the current project env, creates an .env file is missing "
        Write-Host "hexatown pack                                  "  -NoNewline  -ForegroundColor Green
        Write-Host "Create a package file "
        Write-Host "hexatown pop                                   "  -NoNewline  -ForegroundColor Green
        Write-Host "Change to the last location on stack "
        Write-Host "hexatown self                                  "  -NoNewline  -ForegroundColor Green
        Write-Host "Open the CLI code in editor"
        Write-Host "hexatown src                                   "  -NoNewline  -ForegroundColor Green
        Write-Host "Change location to {pb}/src/jobs/powershell    "
        Write-Host "hexatown data                                  "  -NoNewline  -ForegroundColor Green
        Write-Host "Open explorer in env default data folder"
        Write-Host "hexatown version                               "  -NoNewline  -ForegroundColor Green
        Write-Host "Show version"
        Write-Host "hexatown demo                                  "  -NoNewline  -ForegroundColor Green
        Write-Host "Run a demonstration"
        Write-Host "hexatown install                               "  -NoNewline  -ForegroundColor Green
        Write-Host "Update HEXATOWN helper to latest version       "
        Write-Host "hexatown powerbrick <action>                   "  -NoNewline  -ForegroundColor Green
        Write-Host "Support PowerBrick registration on your local machine"
        Write-Host "hexatown pb <action>                           "  -NoNewline  -ForegroundColor Green
        Write-Host "Support PowerBrick registration on your local machine"



    }
    else {
        switch ($forArgument.toUpper()) {
            PACK
               { write-host "You pack by ...." } 
            POWERBRICK 
               { Write-PowerBrick-HelpForPowerBrick } 
            PB { Write-PowerBrick-HelpForPowerBrick } 
            GO {
                write-host "Launch instance specific urls" -ForegroundColor Black -BackgroundColor White
                Write-Host "hexatown go <destination> [instance] "  -ForegroundColor Green
                Write-Host " "  
            
                Write-Host "hexatown go code       "  -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to Code+Test console"
                Write-Host "hexatown go monitor    "  -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to Monitor console"
                Write-Host "hexatown go kudo       "  -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to KUDO PowerShell debug console"
                Write-Host "hexatown go insight    " -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to Insight Live Metrics"
                Write-Host "hexatown go site       " -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to Azure App Site"
                Write-Host "hexatown go func       " -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to Azure App Site Functions Area"
                Write-Host "hexatown go functions  " -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to Azure App Site Functions Area"
                Write-Host "hexatown go sp         " -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to SharePoint site contents"
                Write-Host "hexatown go sharepoint " -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to SharePoint site contents"
                Write-Host "hexatown go edit       " -NoNewline  -ForegroundColor Green
                Write-Host "Navigate to PowerApps studio"
                Write-Host "hexatown go run        " -NoNewline  -ForegroundColor Green
                Write-Host "Run Primary PowerApps"
            
            } 
            Default {
                ShowErrorMessage "Cannot show help for '$forArgument' "
            }
        }
    }
}

function ShowErrorMessage($message) {

    Write-Host $message -ForegroundColor:Red

    
}
function CreateCoreList($hexatown) {
    $loglist = @'
{
    "description":  "",
    
    "displayName":  "Log",
    "list":  {
                 "contentTypesEnabled":  false,
                 "hidden":  false,
                 "template":  "genericList"
             },
    "columns":  [
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Title",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "id":  "fa564e0f-0c70-4ab9-b863-0177e6ddd247",
                        "indexed":  false,
                        "name":  "Title",
                        "readOnly":  false,
                        "required":  true,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Compliance Asset Id",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "ComplianceAssetId",
                        "readOnly":  true,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "System",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "System",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Sub System",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "SubSystem",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Status",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "Status",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Quantity",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "Quantity",
                        "readOnly":  false,
                        "required":  false,
                        "number":  {
                                       "decimalPlaces":  "none",
                                       "displayAs":  "number",
                                       "maximum":  1.7976931348623157E+308,
                                       "minimum":  -1.7976931348623157E+308
                                   }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "System Reference",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "SystemReference",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Details",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "Details",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  true,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  6,
                                     "textType":  "plain"
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Host",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "Host",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Identifier",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "Identifier",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Workflow",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "Workflow",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    },
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Quantifier",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "indexed":  false,
                        "name":  "Quantifier",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  false,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  0,
                                     "maxLength":  255
                                 }
                    }
                ]
}

'@

    $propertieslist = @'
{
    "description":  "",
    "displayName":  "PropertyBag",
    "list":  {
                 "contentTypesEnabled":  false,
                 "hidden":  false,
                 "template":  "genericList"
             },
    "columns":  [
                    {
                        "columnGroup":  "Custom Columns",
                        "description":  "",
                        "displayName":  "Value",
                        "enforceUniqueValues":  false,
                        "hidden":  false,
                        "id":  "2f3ccd45-6989-416e-bf9f-2302bcccf089",
                        "indexed":  false,
                        "name":  "Value",
                        "readOnly":  false,
                        "required":  false,
                        "text":  {
                                     "allowMultipleLines":  true,
                                     "appendChangesToExistingText":  false,
                                     "linesForEditing":  6,
                                     "textType":  "plain"
                                 }
                    }
                ]
}


'@

    GraphAPI $hexatown POST "$($hexatown.site)/lists" $loglist
    GraphAPI $hexatown POST "$($hexatown.site)/lists" $propertieslist

}



function Go($instance, $arg1, $arg2, $arg3) {
    
    $urls = @{}
    $area = $arg1
    if ($null -eq $arg2 ) {
        $environment = "prod"
    }
    else {
        $environment = $arg2
    }
    $codehost = $instance.$environment
    if ($null -eq $codehost) {
        ShowErrorMessage "NO INSTANCE FOUND WITH ENVIRONMENT NAME '$environment'"
        return
    }
    
    $name = $codehost.azureapp
    $azureresourceurl = "https://portal.azure.com/#@$($codehost.tenant)/resource/subscriptions/$($codehost.subscription)/resourceGroups/$($codehost.resourceGroup)"

    $siteurlPrefix = "https://portal.azure.com/#blade/WebsitesExtension/FunctionMenuBlade/"
    $siteurlSuffix = "/resourceId/%2Fsubscriptions%2F$($codehost.subscription)%2FresourceGroups%2F$($codehost.resourceGroup)%2Fproviders%2FMicrosoft.Web%2Fsites%2F$($codehost.site)%2Ffunctions%2F$($codehost.function)"

    $urls.kudo = "https://$name.scm.azurewebsites.net/DebugConsole/?shell=powershell"
    $urls.insight = "$azureresourceurl/providers/microsoft.insights/components/$($codehost.insights)/quickPulse"
    $urls.site = "$azureresourceurl/providers/Microsoft.Web/sites/$($codehost.site)/appServices"
    $urls.code = "$siteurlPrefix$("code")$siteurlSuffix"
    $urls.monitor = "$siteurlPrefix$("monitor")$siteurlSuffix"
    $urls.func = "$azureresourceurl/providers/Microsoft.Web/sites/$($codehost.site)/functionsList"
    $urls.functions = "$azureresourceurl/providers/Microsoft.Web/sites/$($codehost.site)/functionsList"
    $urls.sharepoint = "$($codehost.sharepoint)/_layouts/15/viewlsts.aspx?view=14"
    $urls.sp = "$($codehost.sharepoint)/_layouts/15/viewlsts.aspx?view=14"
    $urls.edit = "$($codehost.powerappsdeveloper)"
    $urls.run = "$($codehost.powerappsruntime)"


    $url = $urls.$area
    
    if ($null -eq $url ) {
        ShowErrorMessage "Cannot find '$area' in instance '$arg2' "
        return
    }
    write-host $url
    Start-Process $url
    
  
}

function CreateLists($hexatown) {



}


function Pack($root) {
    
    Compress-Archive -LiteralPath "$root\src" -DestinationPath "$root\src" -Force
    $path = "explorer $root,select,src.zip"
    Invoke-Expression $path
  
  
}

function Init($root, $packageNamePart1,$packageNamePart2,$packageNamePart3,$packageNamePart4) {
    $folderName = $packageNamePart1
    if ($null -ne $packageNamePart2){$folderName += " $packageNamePart2"}
    if ($null -ne $packageNamePart3){$folderName  += " $packageNamePart3"}
    if ($null -ne $packageNamePart4){$folderName  += " $packageNamePart4"}

    if ($null -eq $folderName  ) {
        ShowErrorMessage "Missing project name"
        return
    }

    $packageName  = $folderName.replace(' ', '-').ToLower()
    
    $packageFolder = Join-Path  $root.Path  $folderName 
    $tempFolder = Join-Path $packageFolder "temp"
    $packagefile = Join-Path  $packageFolder "package.json"
    
    if ((Test-Path $packageFolder )) {
        ShowErrorMessage "A folder with that name already exists"
        return
    }
    New-Item -Path $root.Path -Name $folderName -ItemType "directory" | Out-Null
    New-Item -Path $packageFolder -Name "temp" -ItemType "directory" | Out-Null

    $defaultValues = @"
{
  "name": "$packageName",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "run": "hexatown run",
    "pack" : "hexatown pack"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": ""
}

"@
    $defaultValues | Out-File $packagefile
    Set-Location $packageFolder    
    $file = Join-Path $tempFolder "template.zip"

    Download-File "https://github.com/Hexatown/templates/archive/main.zip" $file
    
    Expand-Archive -Path "$file" -DestinationPath $tempFolder -Force 
    Copy-Item "$tempFolder\templates-main\*"  -Destination $packageFolder -Force -Recurse
    Remove-Item -Path $tempFolder -Force -Recurse 
    
    $srcPath = Join-Path $packageFolder "src"
    $jobsPath = Join-Path $srcPath "jobs"
    $powershelljobsPath = Join-Path $jobsPath "powershell"
    $hexatownHelperFile = Join-Path $powershelljobsPath ".hexatown.com.ps1"
    Download-File "https://raw.githubusercontent.com/Hexatown/core/master/src/jobs/powershell/.hexatown.com.ps1" $hexatownHelperFile
    
    write-host "Project file created" -ForegroundColor DarkGreen

    OpenEnv $packageName
    Editor $packageFolder    
}

function Editor($root) {
    $timerJob = "$root\run.ps1"
    $rootJob = "$root\src\jobs\powershell\index.ps1"
    $helperJob = "$root\src\jobs\powershell\.hexatown.com.ps1"
    Invoke-Expression "ise ""$helperJob,$timerjob,$rootjob"""    
    
    
}

function Self($root) {
    $self = "$PSScriptRoot\hexatown.ps1"
    Home
    Invoke-Expression "ise ""$self"""    
    
    
}

function Home() {
    $self = "$PSScriptRoot"
    
    Push-Location $self
    
}

function GoDataEnv() {
    ## TODO Load .env file and open Explerer in data path
    write-error "Not implemented"
    exit
    Push-Location     ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData) + "\hexatown.com\") 
    
}



function OpenEnv($name) {
    $environmentPath = ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)) 
    $appdir = $environmentPath + "\hexatown.com\" + $name
    $envfile = $environmentPath + "\hexatown.com\" + $name + "\.env"
    $defaultenvfile = $environmentPath + "\hexatown.com\.default\.env"

    write-host $appdir 
    if (!(Test-Path $appdir)) {
        New-Item -ItemType Directory -Force -Path $appdir
    }
    if (!(Test-Path $envfile )) {

        if (Test-Path $defaultenvfile){
        $defaultValues = Get-Content -Path $defaultenvfile -raw
        }else{
        $defaultValues = @"
APPCLIENT_ID=
APPCLIENT_SECRET=
APPCLIENT_DOMAIN=
SITEURL=https://xxxxxxx.sharepoint.com/sites/hexatown
AADDOMAIN=xxxxxx.com
"@
}
        $defaultValues | Out-File $envfile
        
    }
    
    # Invoke-Expression "explorer $appdir"
    Push-Location $appdir
    Invoke-Expression "ise $envfile"
    
}

function OpenSrc($path) {
    Push-Location "$path\src\jobs\powershell"
    
}


function GetInstance($instanceFile) {
        
    if ((Test-Path $instanceFile  )   ) {
            
        $instanceText = Get-Content $instanceFile -Encoding UTF8 | Out-String 
        

        $results = ConvertFrom-Json -InputObject $instanceText 
        $instances = @{}
        foreach ($item in $results.hosts) {
        
            $instances.Add($item.name, $item)
        }
        return $instances
    }
    else {
        return @{}
    }
        
}

function Show-Hexatown-Version() {
    Write-Host "hexatown.com " -ForegroundColor Green -NoNewline
    Show-Hexatown-CLIVersion
}



function Get-Hexatown-PowerBricks() {
    $pp = "$PSScriptRoot\powerbricks.json"
    
    
    
    if (Test-Path($pp)) {
        $powerbricks = Get-Content -Path $pp -Raw  | ConvertFrom-Json
    }

    if ($null -eq $powerbricks) { 
    $returnValue = [System.Collections.ArrayList]@() 
    }
    else
    {
    
    if ("Object[]" -ne  $powerbricks.GetType().Name) {
        
        write-host "converted returning new array"
        [System.Collections.ArrayList]$returnValue = [System.Collections.ArrayList]::new()
        $returnValue.Add($powerbricks)
        
        
    }else{
        $returnValue=  $powerbricks
    }    
    }    
    
     
     write-host $returnValue | ConvertTo-Json 
     
    return $returnValue
}

function Get-Hexatown-PowerBrick($name) {
    $powerbricks = Get-Hexatown-PowerBricks 
    $counter = 0
    foreach ($powerbrick in $powerbricks) {
        $counter ++
        if ($name -eq $counter){
            $existing = $powerbrick
        }
        if ($powerbrick.name -eq $name) {
            $existing = $powerbrick
        }        
        if ($powerbrick.alias -eq $name) {
            $existing = $powerbrick
        }        
        
    }
    return $existing 
}

function Push-Hexatown-PowerBrickLocation($name) {
    $powerBrick = Get-Hexatown-PowerBrick $name

    if ($null -eq $powerBrick) {
        write-host "powerbrick not found '$name'" -ForegroundColor Yellow
        return
    }
    $metadata = Read-Hexatown-Metadata $powerBrick.path
    write-host "Changing to '$($metadata.name)'  "
    write-host "Changing to '$($powerBrick.path)'  "
    Push-Location $powerBrick.path
}

function List-Hexatown-PowerBrickLocations() {
$powerbricks = Get-Hexatown-PowerBricks 
    $counter = 0
    foreach ($powerbrick in $powerbricks) {
        $counter++
        if ($null -ne $powerbrick.alias){
            $name = "$($powerbrick.name) ($($powerbrick.alias))"
        }else
        {
        $name = $powerbrick.name
    }
        write-host ("{0,3}" -f $counter) "" -ForegroundColor Yellow -NoNewline
        write-host "$name $(' '* (30-$name.Length))"   "" -ForegroundColor Yellow -NoNewline
        write-host $powerbrick.path -ForegroundColor White
    }

    write-host ""
    write-host "Hint:"
    Write-Host "You can change the location to a given PowerBrick by writting" -ForegroundColor Green
    Write-Host "hexatown powerbrick go 1         " -ForegroundColor Yellow -NoNewline ; Write-Host "Change PowerBrick #1"
    Write-Host "hxt pb go 1                      " -ForegroundColor Yellow -NoNewline ; Write-Host "Does the same"
}

function Show-Hexatown-CodeContext($invocation){


    write-host "MyCommand>" $invocation.MyCommand "<"
        # write-host (ConvertTo-Json -InputObject $invocation -depth 1)

}
function Register-Hexatown-PowerBrick($path,$alias) {
    $metadata = Read-Hexatown-PowerBrickMetadata $path    
    if ($null -eq $metadata) {
        write-host "No project file at this location" -ForegroundColor Red
        return
    }



    $powerbricks = Get-Hexatown-PowerBricks 
    if ($null -eq $powerbricks) {
        Show-Hexatown-CodeContext $MyInvocation
        write-host "Fatal error loading PowerBricks repository" -ForegroundColor Red
        write-host $PSScriptRoot -ForegroundColor Red
        exit
    }
    
    # write-host "returned" $powerbricks.GetType().Name 
    $existing = $false
    foreach ($powerbrick in $powerbricks) {
        if ($powerbrick.name -eq $metadata.name) {
            write-host "Power*Brick with that name already registrated" -ForegroundColor Yellow
            $existing = $true
        }        
        if ($null -ne $alias -and $powerbrick.alias -eq $alias) {
            write-host "Power*Brick with that alias already registrated to '$($metadata.name)' at $($metadata.path) " -ForegroundColor Yellow
            $existing = $true
        }        
        
    }
    
    if ($existing ) {
        
        return
    }

#    write-host "before" $powerbricks.GetType().Name $powerbricks.Count
    write-host "Power⚙️Brick added" -ForegroundColor Green

    $powerbricks += @{
        name = $metadata.name
        path = $path.Path
    }
    $json = ConvertTo-Json -InputObject $powerbricks -Depth 2
    Out-File "$PSScriptRoot\powerbricks.json" -InputObject $json

}

function powerbrick($path, $arg1, $arg2) {
    if ($null -ne $arg1) {
        $typeName = $arg1.GetType().Name
        if ($typeName -eq "Int32") { 
        
            Push-Hexatown-PowerBrickLocation $arg1
            return
        }
        $command = $arg1.toUpper()
    }
    
    switch ($command) {
        REGISTER { Register-Hexatown-PowerBrick $path arg2 }
        GO { Push-Hexatown-PowerBrickLocation $arg2 }
        LIST { List-Hexatown-PowerBrickLocations }
        Default {
            Write-Host "Unknown command " -NoNewline -ForegroundColor Red
            Write-Host $command -ForegroundColor Yellow
            
            ShowHelp "Powerbrick"
            write-host ""
            write-host "Anyhow, you might like a list of current PowerBricks"
            write-host "So here they are ..."
            List-Hexatown-PowerBrickLocations

            

        }

    }

}

function Start-Hexatown-Demo(){


}

function PushHelperFileChanges() {
$master = ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Hexatown/core/master/src/jobs/powershell/.hexatown.com.ps1'))


    $projects = get-childitem -Path $root -Directory

    # $master = Get-Content "$PSScriptRoot\.hexatown.com.ps1" 
    $projects = Get-Hexatown-PowerBricks
    foreach ($project in $projects) {

        
        $projectPath = $project.path
        if (Test-Path "$projectPath/package.json") {
        
            

             $projectconfig = Get-Content (Join-Path $projectPath "package.json")  -Raw | ConvertFrom-Json 

            if (!$projectconfig.hexatown.isMaster) {
             

                $helpers = Get-ChildItem -Path "$projectPath/*.ps1"  -Recurse | Where-Object Name -eq ".hexatown.com.ps1" 
                foreach ($helper in $helpers) {
                 
                    $slave = Get-Content $helper.VersionInfo.FileName  -Raw
                
                    $diff = Compare-Object -ReferenceObject $master -DifferenceObject $slave

                    if ($null -ne $diff) {
                        $helper.VersionInfo.FileName 
                        $diff | ft
                        write-host "Updating $($project.name)  $($helper.VersionInfo.FileName) "
                        Out-File $helper.VersionInfo.FileName -InputObject $master 
                    }

             
                }

            }
        }
    }
}

function PushHelperFileChange($projectPath) {
$master = ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Hexatown/core/master/src/jobs/powershell/.hexatown.com.ps1'))


        
        
        if (Test-Path "$projectPath/package.json") {
        
            

             $projectconfig = Get-Content (Join-Path $projectPath "package.json")  -Raw | ConvertFrom-Json 

            if (!$projectconfig.hexatown.isMaster) {
             

                $helpers = Get-ChildItem -Path "$projectPath/*.ps1"  -Recurse | Where-Object Name -eq ".hexatown.com.ps1" 
                foreach ($helper in $helpers) {
                 
                    $slave = Get-Content $helper.VersionInfo.FileName  -Raw
                
                    $diff = Compare-Object -ReferenceObject $master -DifferenceObject $slave

                    if ($null -ne $diff) {
      #                  $helper.VersionInfo.FileName 
                        $diff | ft
                        write-host "Updating $($project.name)  $($helper.VersionInfo.FileName) "
                        Out-File $helper.VersionInfo.FileName -InputObject $master 
                    }

             
                }

            }
        }

}

function Install(){

$brick = Read-Hexatown-PowerBrickMetadata  (Get-Location)
if ($null -ne $brick){

    PushHelperFileChange (Get-Location)

}else{

    write-host "No PowerBrick in this directory" -ForegroundColor Yellow 
}

}

function appendToArchive($pattern, $destFile){
    if (test-path $pattern) {
    
    Compress-Archive -LiteralPath $pattern -DestinationPath $destFile   -Update | Out-Null
    }
}

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name) 
}
function ZipEnv(){

$envPath = ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData) + "\hexatown.com\") 


$tempDir =  New-TemporaryDirectory
$destFile  = Join-Path (Get-Location) "hexatown.env.zip"

Invoke-Expression "robocopy ""$envPath"" ""$tempDir/hexatown.com"" /s /xf *.json /xf *.log /xf *.csv /xf *.txt /xf *.xml /xd .hexatown /np /ndl"
# Push-Location $tempDir


Compress-Archive  -LiteralPath "$tempDir/hexatown.com" -DestinationPath $destFile   -Force 
   




}

function Start-Hexatown-PowerBrick($alias,$arg1,$arg2,$arg3, $arg4, $arg5){
   
   $pb = Get-Hexatown-PowerBrick $alias
   if ($null -eq $pb){
        write-host "PowerBrick not found" -ForegroundColor Red
        return
   }
   
#  write-host "Starting $($pb.name)" -ForegroundColor Green
#  write-host "Starting $($pb.path)" -ForegroundColor Green

   $filepath = Join-Path $pb.path "$arg1.ps1" 
   if (!(Test-Path $filepath)){
        write-host "Command not found '$arg1'" -ForegroundColor Red
        return
   }
   
   . $filepath $arg2 $arg3 $arg4 $arg5

   

}

<#********************************************************************************************


**********************************************************************************************
#>





$path = Get-Location
$arg0 = $args[0]
$arg1 = $args[1]
$arg2 = $args[2]
$arg3 = $args[3]
$arg4 = $args[4]
$arg5 = $args[5]
$arg6 = $args[6]

<#
$path = "C:\hexatown.com\InfoCast"
$arg0 = "go"
$arg1 = "prod"
$arg2 = "site"
#>
if ($null -eq $arg0) {
    ShowErrorMessage "Missing arguments "
    write-host "use  'hexatown help' for a list or arguments  "
    Exit

}

$command = $arg0.toUpper()
switch ($command) {
    DIR  { Invoke-Expression "explorer ." }
    DEMO { Start-Hexatown-Demo $arg1}
    VERSION { Show-Hexatown-Version }
    HELP { ShowHelp $arg1 }
    INIT { Init $path $arg1 $arg2 $arg3 }
    SELF { Self $path }
    HOME { Home }
    DATA { GoDataEnv }
    POP { Pop-Location }
    INSTALL { Install}
    ZIPENV { ZipEnv }
    RUN  { Start-Hexatown-PowerBrick $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 }

    PB {
        powerbrick $path $arg1 $arg2 
                      

    }
    POWERBRICK {
        powerbrick $path $arg1 $arg2 
                      

    }

    Default {
        

        $projectFile = "$path/package.json"
        $instanceFile = "$path/.hexatown.com.json"

        if (!(Test-Path $projectFile  )   ) {
            ShowErrorMessage "No project file found "
            
            write-host "use  'hexatown init' to setup a new project here"
            ShowHelp 
            Exit

        }
        $instances = GetInstance $instanceFile


        $project = Get-Content $projectFile | ConvertFrom-Json
        
        switch ($command) {
            EDIT { Editor $path }
            SRC { OpenSrc $path }
            ENV { OpenEnv $project.name }
            PACK { 
                Write-Host "Packing $($project.name)"
                Pack $path 
            }
            GO { 
                Write-Host "Opening $arg1 $arg2"
                Go $instances $arg1 $arg2
            }
            
            Default {
                ShowErrorMessage "Unknown arguments '$($arg0)' "
                write-host "use  'hexatown help' for a list or arguments  "
            
        
            }
            
        }

    }
}




<#
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-psbreakpoint?view=powershell-7.1
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/remove-psbreakpoint?view=powershell-7.1
Set-PSBreakpoint -Command "checklog"
get-psbreakpoint | remove-psbreakpoint

#>
