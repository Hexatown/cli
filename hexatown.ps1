
function DotEnvConfigure() {
    $debug = $false
    $path = $PSScriptRoot 
    $loop = $true
    
    do {
        $filename = "$path\.env"
        if ($debug) {
            write-output "Checking $filename"
        }
        if (Test-Path $filename) {
            if ($debug) {
                write-output "Using $filename"
            }
            $lines = Get-Content $filename
             
            foreach ($line in $lines) {
                    
                $nameValuePair = $line.split("=")
                if ($nameValuePair[0] -ne "") {
                    if ($debug) {
                        write-host "Setting >$($nameValuePair[0])<"
                    }
                    $value = $nameValuePair[1]
                    
                    for ($i = 2; $i -lt $nameValuePair.Count; $i++) {
                        $value += "="
                        $value += $nameValuePair[$i]
                    }

                    if ($debug) {
                        write-host "To >$value<"
                    }    
                    [System.Environment]::SetEnvironmentVariable($nameValuePair[0],  $value)
                }
            }
    
            $loop = $false
        }
        else {
            $lastBackslash = $path.LastIndexOf("\")
            if ($lastBackslash -lt 4) {
                $loop = $false
                if ($debug) {
                    write-output "Didn't find any .env file  "
                }
            }
            else {
                $path = $path.Substring(0, $lastBackslash)
            }
        }
    
    } while ($loop)
    
}
    

function ShowHelp($forArgument) {

    Write-Host "Help" 

    if ($null -eq $forArgument) {
        Write-Host "General help" 
        
        Write-Host "hexatown go <destination> [instance]           "  -NoNewline  -ForegroundColor Green
        Write-Host "Navigate to <destination> in optional instance "
        Write-Host "hexatown init <destination>                    "  -NoNewline  -ForegroundColor Green
        Write-Host "Create a project file "
        Write-Host "hexatown pack                                  "  -NoNewline  -ForegroundColor Green
        Write-Host "Create a package file "

    }
    else {
        switch ($forArgument.toUpper()) {
            PACK { write-host "You pack by ...." } 
            GO   { write-host "Launch instance specific urls" -ForegroundColor Black -BackgroundColor White
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


function Go($instance, $arg1, $arg2,$arg3) {
    
    $urls = @{}
    $area = $arg1
    if ($null -eq $arg2 ){
        $environment = "prod"
    }else{
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



function Pack($root) {
    
    Compress-Archive -LiteralPath "$root\src" -DestinationPath "$root\src" -Force
    $path = "explorer $root,select,src.zip"
    Invoke-Expression $path
  
  
}

function Init($root,$packageName) {
    if ($null -eq $packageName ) {
        ShowErrorMessage "Missing project name"
        return
    }

    $packagefile = $root.Path + "\package.json"
    
    if ((Test-Path $packagefile )) {
        ShowErrorMessage "Project have already been created"
        return
    }
    
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
        
    write-host "Project file created" -ForegroundColor DarkGreen
    
}

function Editor($root) {
    $timerJob = "$root\run.ps1"
    $rootJob = "$root\src\jobs\powershell\index.ps1"
    Invoke-Expression "ise ""$timerjob,$rootjob"""    
    
    
}

function OpenEnv($name) {
    $environmentPath = ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)) 
    $appdir = $environmentPath + "\hexatown.com\"+ $name
    $envfile = $environmentPath + "\hexatown.com\"+ $name + "\.env"
    write-host $appdir 
    if (!(Test-Path $appdir)) {
        New-Item -ItemType Directory -Force -Path $appdir
    }
    if (!(Test-Path $envfile )) {
        $defaultValues = @"
APPCLIENT_ID=
APPCLIENT_SECRET=
APPCLIENT_DOMAIN=
SITEURL=https://xxxxxxx.sharepoint.com/sites/hexatown
AADDOMAIN=xxxxxx.com
"@
        $defaultValues | Out-File $envfile
        
    }
    $path = "explorer $appdir"
    Invoke-Expression $path
  
    $editor = "notepad $envfile"
    Invoke-Expression $editor
    
}


function GetInstance($instanceFile) {
        
    if ((Test-Path $instanceFile  )   ) {
            
        $instanceText = Get-Content $instanceFile -Encoding UTF8 | Out-String 
        

        $results = ConvertFrom-Json -InputObject $instanceText 
        $instances = @{}
        foreach ($item in $results.hosts) {
        
            $instances.Add($item.name,$item)
        }
        return $instances
    }
    else {
        return @{}
    }
        
}
<#********************************************************************************************


**********************************************************************************************
#>

Write-Host "hexatown.com " -ForegroundColor Green -NoNewline
Write-Host "version 0.1.2" -ForegroundColor:DarkGray


$path = Get-Location
$arg0 = $args[0]
$arg1 = $args[1]
$arg2 = $args[2]
$arg3 = $args[3]

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
    HELP { ShowHelp $arg1 }
    INIT { Init $path $arg1 }
    Default {
        

        $projectFile = "$path/package.json"
        $instanceFile = "$path/.hexatown.com.json"

        if (!(Test-Path $projectFile  )   ) {
            ShowErrorMessage "No project file found "
            write-host "use  'hexatown init' to setup a new project"
            Exit

        }
        $instances = GetInstance $instanceFile


        $project = Get-Content $projectFile | ConvertFrom-Json
        
        switch ($command) {
            EDITOR { Editor $path  }
            ENV  { OpenEnv $project.name }
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
