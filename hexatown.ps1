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
    }
    else {
        switch ($forArgument.toUpper()) {
            PACK { write-host "You pack by ...." } 
            GO   { write-host "Launch instance specific urls" -ForegroundColor Black -BackgroundColor White
            
            Write-Host "hexatown go code "  -NoNewline  -ForegroundColor Green
            Write-Host "Navigate to Code+Test console"
            Write-Host "hexatown go monitor "  -NoNewline  -ForegroundColor Green
            Write-Host "Navigate to Monitor console"
            Write-Host "hexatown go kudo "  -NoNewline  -ForegroundColor Green
            Write-Host "Navigate to KUDO PowerShell debug console"
            Write-Host "hexatown go insight " -NoNewline  -ForegroundColor Green
            Write-Host "Navigate to Insight Live Metrics"
            Write-Host "hexatown go site " -NoNewline  -ForegroundColor Green
            Write-Host "Navigate to Azure App Site"
            Write-Host "hexatown go sharepoint " -NoNewline  -ForegroundColor Green
            Write-Host "Navigate to SharePoint site contents"
            
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
    $codehost = $instance.$arg1
    if ($null -eq $codehost) {
        ShowErrorMessage "Cannot find instance '$arg1' "
        return
    }
    
    $name = $codehost.azureapp
    $azureresourceurl = "https://portal.azure.com/#@$($codehost.tenant)/resource/subscriptions/$($codehost.subscription)/resourceGroups/$($codehost.resourceGroup)"

    $siteurlPrefix = "https://portal.azure.com/#blade/WebsitesExtension/FunctionMenuBlade/"
    $siteurlSuffix = "/resourceId/%2Fsubscriptions%2F$($codehost.subscription)%2FresourceGroups%2F$($codehost.resourceGroup)%2Fproviders%2FMicrosoft.Web%2Fsites%2F$($codehost.site)%2Ffunctions%2F$($codehost.function)"

    $urls.kudo = "https://$name.scm.azurewebsites.net/DebugConsole/?shell=powershell"
    $urls.insight = "$azureresourceurl/providers/microsoft.insights/components/$($codehost.insights)/quickPulse"
    $urls.site = "$azureresourceurl/providers/Microsoft.Web/sites/$($codehost.site)/appServices"
    $urls.code = "$siteurlPrefix$("code")$siteurlPrefix"
    $urls.monitor = "$siteurlPrefix$("monitor")$siteurlPrefix"
    $urls.sharepoint = "$($codehost.sharepoint)/_layouts/15/viewlsts.aspx?view=14"

    $url = $urls.$arg2
    if ($null -eq $url ) {
        ShowErrorMessage "Cannot find '$arg2' in instance '$arg1' "
        return
    }
    write-host $url
    Start-Process $url
    
  
}



function Pack($root) {
    
    Compress-Archive -LiteralPath "$root\src" -DestinationPath "$root\src" -Force
    Start-Process "explorer ./src.zip"
  
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
Write-Host "version 0.1" -ForegroundColor:DarkGray


$path = Get-Location
$arg0 = $args[0]
$arg1 = $args[1]
$arg2 = $args[2]
$arg3 = $args[3]

<#
$path = "C:\hexatown.com\xxx"
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
    INIT { Init $arg1 $arg2 $arg3 }
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








