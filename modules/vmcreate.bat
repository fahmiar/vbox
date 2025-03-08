@echo off
:: setlocal EnableDelayedExpansion


:: Set description
for /F "delims=" %%n in ('type "%VM_PATH%\network-config"') do (
  set "line=%%n"
  :: Replace the line feed with \n
  set "VM_DESC=!VM_DESC!!line!\n"
)
set "VM_DESC=$'!VM_DESC!'"

set "VBOXMANAGE_PATH=%VBOX_MSI_INSTALL_PATH%VBoxManage.exe"
set "line=0"

for /f "tokens=* delims=" %%A in ('type "%APP_PATH%\modules\vmscript.csv"') do (
  set /a line+=1

  if !line! gtr 1 (
    for /f "tokens=1,2 delims=," %%i in ("%%A") do (
      set todo=%%j

      :: Perform the replacement
      set "todo=!todo:$HOMEPATH$=%HOMEDRIVE%%HOMEPATH%!"
      set "todo=!todo:$IMG_PATH$=%IMG_PATH%!"
      set "todo=!todo:$IMG_OSTYPE$=%IMG_OSTYPE%!"
      set "todo=!todo:$VBOX_PATH$=%VBOX_PATH%!"
      set "todo=!todo:$VM_PATH$=%VM_PATH%!"
      set "todo=!todo:$VM_NAME$=%VM_NAME%!"
      set "todo=!todo:$VM_CPUS$=%VM_CPUS%!"
      set "todo=!todo:$VM_MEMORY$=%VM_MEMORY%!"
      set "todo=!todo:$VM_DESC$=%VM_DESC%!"

      :: check any remark command
      set sign=%%i
      set sign=!sign:~0,1!

      if not "!sign!"==":" (
        call "%APP_PATH%\modules\color.bat"
        
        if "--debug"=="" (
          echo %COLOR_BRIGHTCYAN%^> %%i%COLOR_RESET%
        ) else (
          echo %COLOR_BRIGHTCYAN%^> %%i%COLOR_RESET% !todo!
        )

        "%VBOXMANAGE_PATH%" !todo!
        echo.
      )
    )
  )
)
