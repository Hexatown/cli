function download($moduleName){

$modulePath = Join-path $PSScriptRoot "modules"
if (!(test-path $modulePath)){
    New-Item -ItemType Directory -Force -Path $modulePath | Out-Null
} 


$moduleNamePath = join-path $modulePath $moduleName
if (!(Test-Path $moduleNamePath)){
    write-host "Downloading $moduleName"
    Save-Module -Name $moduleName -Path $modulePath -Confirm:$false #-Name PnP.PowerShell 
}


}


download "PSReadLine"