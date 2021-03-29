$zipFilename ="$PSScriptRoot\hexatown.zip" 
if (Test-Path($zipFilename)){
    Remove-Item  $zipFilename -Force

}

Compress-Archive -LiteralPath "$PSScriptRoot\hexatownInstall.ps1" -DestinationPath "$PSScriptRoot\hexatown" -force
Compress-Archive -LiteralPath "$PSScriptRoot\hexatown.cmd" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\hexatown.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\hexa.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\hxt.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\h.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\xt.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\t.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\hx.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\x.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\gui.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\hexatree.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\InstallPackage.ps1" -DestinationPath "$PSScriptRoot\hexatown" -Update

Compress-Archive -LiteralPath "$PSScriptRoot\package.json" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\src" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\modules" -DestinationPath "$PSScriptRoot\hexatown" -Update
Compress-Archive -LiteralPath "$PSScriptRoot\img" -DestinationPath "$PSScriptRoot\hexatown" -Update

