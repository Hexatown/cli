$zipFilename ="$PSScriptRoot\hexatown.zip" 
if (Test-Path($zipFilename)){
    Remove-Item  $zipFilename -Force

}

Compress-Archive -LiteralPath "$PSScriptRoot\hexatownInstall.ps1" -DestinationPath "$PSScriptRoot\hexatown" -force
Compress-Archive -LiteralPath "$PSScriptRoot\hexatown.cmd" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\hexatown.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\hxt.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\package.json" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\src" -DestinationPath "$PSScriptRoot\hexatown" -Update

