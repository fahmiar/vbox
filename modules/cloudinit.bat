@echo off
:: setlocal enabledelayedexpansion


cd "%VM_PATH%"

del "%VM_PATH%\user-data" "%VM_PATH%\meta-data" "%VM_PATH%\network-config" "%VM_PATH%\cloud-init.iso"

call "%APP_PATH%\modules\color.bat"
        
:: Read the content of the user-data file into a variable
if "--debug"=="" (
  echo %COLOR_BRIGHTCYAN%^> Write user-data%COLOR_RESET%
) else (
  echo %COLOR_BRIGHTCYAN%^> Write user-data%COLOR_RESET%
)
for /F "delims=" %%n in ('type "%APP_PATH%\config\user-data.yaml"') do (
  set result=%%n

  :: Perform the replacement
  set "result=!result:$VM_USER$=%VM_USER%!"
  set "result=!result:$VM_PASSWORD$=%VM_PASSWORD%!"
  set "result=!result:$IMG_OSTYPE$=%IMG_OSTYPE%!"

  echo !result! >> "%VM_PATH%\user-data"
)


:: Read the content of the meta-data file into a variable
if "--debug"=="" (
  echo %COLOR_BRIGHTCYAN%^> Write meta-data%COLOR_RESET%
) else (
  echo %COLOR_BRIGHTCYAN%^> Write meta-data%COLOR_RESET%
)
for /F "delims=" %%n in ('type "%APP_PATH%\config\meta-data.yaml"') do (
  set result=%%n

  :: Perform the replacement
  set "result=!result:$VM_NAME$=%VM_NAME%!"
  set "result=!result:$IMG_OSTYPE$=%IMG_OSTYPE%!"

  echo !result! >> "%VM_PATH%\meta-data"
)


:: Read the content of the network-config file into a variable
if "--debug"=="" (
  echo %COLOR_BRIGHTCYAN%^> Write network-config%COLOR_RESET%
) else (
  echo %COLOR_BRIGHTCYAN%^> Write network-config%COLOR_RESET%
)
for /F "delims=" %%n in ('type "%APP_PATH%\config\network-config.yaml"') do (
  set result=%%n

  :: Perform the replacement
  set "result=!result:$VM_IP1$=%VM_IP1%!"
  set "result=!result:$VM_IP2$=%VM_IP2%!"

  echo !result! >> "%VM_PATH%\network-config"
)


:: ISO writer https://github.com/PeyTy/xorriso-exe-for-windows/archive/master.zip
SET XORRISO_PATH="%TEMP%\xorriso-exe-for-windows-master\xorriso.exe"
if not exist "%XORRISO_PATH%" (
  curl -L -o "%TEMP%\xorriso.zip" https://github.com/PeyTy/xorriso-exe-for-windows/archive/master.zip
  tar -xf "%TEMP%\xorriso.zip" -C "%TEMP%"
)


if "--debug"=="" (
  echo %COLOR_BRIGHTCYAN%^> Create ISO%COLOR_RESET%
) else (
  echo %COLOR_BRIGHTCYAN%^> Create ISO%COLOR_RESET%
)
""%XORRISO_PATH%"" -as mkisofs ^
                   -o "%VM_PATH%\cloud-init.iso" ^
                   -volid cidata ^
                   -joliet ^
                   -rock ^
                   user-data ^
                   meta-data ^
                   network-config


:: del "%VM_PATH%\user-data" "%VM_PATH%\meta-data" "%VM_PATH%\network-config"

cd "%APP_PATH%"

