@echo off
@echo Starting hexatown Powershell
SET arg1=%~1
SET arg2=%~2
SET arg3=%~3
SET arg4=%~4
SET arg5=%~5
SET arg6=%~6
SET arg7=%~7
SET arg8=%~8
SET arg9=%~9


SET PSScript=C:\programdata\hexatown.com\.hexatown\hexatown.ps1

Powershell -Noexit -ExecutionPolicy Bypass -Command "& '%PSScript%' '%arg1%' '%arg2%' '%arg3%' '%arg4%' '%arg5%' '%arg6%' '%arg7%' '%arg8%' '%arg9%'"