@echo off
::setlocal EnableDelayedExpansion

set "VBOXMANAGE_PATH=%VBOX_MSI_INSTALL_PATH%VBoxManage.exe"

"%VBOXMANAGE_PATH%" list hostonlyifs > "%TEMP%\vboxinfo.txt"

for /f "tokens=1,2 delims=:" %%i in ('type "%TEMP%\vboxinfo.txt"') do (
  set "info=%%j"

  set "info=!info:  =!"
  if "%%i"=="Name" set "HOSTONLY_NAME=!info!


  set "info=!info: =!"
  if "%%i"=="IPAddress" set "HOSTONLY_SUBNET=!info!
)

set "HOSTONLY_SUBNET=!HOSTONLY_SUBNET:~0,-1!