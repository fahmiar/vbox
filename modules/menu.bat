@echo off
:: setlocal enabledelayedexpansion

:: Get total physical memory in megabytes using PowerShell
for /f "usebackq tokens=*" %%A in (`powershell -command "Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory"`) do (
  set TotalPhysicalMemoryBytes=%%A
  set /a TotalPhysicalMemoryMB=!TotalPhysicalMemoryBytes:~0,-6!
)

:: Get free physical memory in megabytes using PowerShell
for /f "usebackq tokens=*" %%A in (`powershell -command "Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty FreePhysicalMemory"`) do (
  set FreePhysicalMemoryKB=%%A
  set /a FreePhysicalMemoryMB=!FreePhysicalMemoryKB:~0,-3!
)

:menu
cls
echo =======================================
echo.         VirtualBox Script
echo =======================================
echo.

:: Read the main menu options from the text file
set line=0
set counter=1

for /f "tokens=* delims=" %%A in ('type "%APP_PATH%\image.csv"') do (
  set /a line+=1

  if !line! gtr 1 (
    set prefix=%%A
    set prefix=!prefix:~0,2!

    if not "!prefix!"=="::" (
      for /f "tokens=1,2 delims=," %%i in ("%%A") do (
        :: Check columns position
        if "!prefix!"=="ht" (
          set "RAW_URL=%%i"
          set "RAW_OSTYPE=%%j"
        ) else (
          set "RAW_OSTYPE=%%i"
          set "RAW_URL=%%j"
        )
      )

      set "option[!counter!]=!RAW_OSTYPE!,!RAW_URL!"
      for %%a in ("!RAW_URL!") do set "optext=%%~nxa"
      echo !counter!. !optext!
      set /a counter+=1
    )
  )
)
set "option[!counter!]=Exit"
echo !counter!. Exit

set /p choice="Enter your %COLOR_BRIGHTCYAN%OS%COLOR_RESET% choice (between 1-%counter%, default is %COLOR_BRIGHTYELLOW%3%COLOR_RESET%): "

:: Check if the choice is valid
set valid=0
for /L %%i in (1,1,%counter%) do (
  if "!choice!"=="%%i" set valid=1
)

if not !valid!==1 (
  echo Invalid choice, please try again.
  pause
  goto :menu
)

:: Execute the chosen main option
set chosen_option=!option[%choice%]!

if "!chosen_option!"=="Exit" goto :eof

for /f "tokens=1,2 delims=," %%i in ("!chosen_option!") do (
  set "IMG_OSTYPE=%%i"
  for %%f in ("%%j") do (
    set "IMG_EXT=%%~xf"
    set "IMG_FILE=%%~nf"
  )
)

:: VM name
echo.
set /p --name=Enter %COLOR_BRIGHTCYAN%VM name%COLOR_RESET% (default is %COLOR_BRIGHTYELLOW%%VM_NAME%%COLOR_RESET%):
if not "!--name!"=="" set VM_NAME=!--name!

:: CPUs
echo.
set /p --cpus=Enter %COLOR_BRIGHTCYAN%CPUs%COLOR_RESET% (between 1-%NUMBER_OF_PROCESSORS%, default is %COLOR_BRIGHTYELLOW%%VM_CPUS%%COLOR_RESET%):
if not "!--cpus!"=="" set VM_CPUS=!--cpus!

:: Memory
echo.
set /p --memory=Enter %COLOR_BRIGHTCYAN%Memory%COLOR_RESET% (between 4-!TotalPhysicalMemoryMB!MB, default is %COLOR_BRIGHTYELLOW%%VM_MEMORY%MB%COLOR_RESET%):
if not "!--memory!"=="" set VM_MEMORY=!--memory!

:: IP
echo.
set /p --ip1=Enter %COLOR_BRIGHTCYAN%IP 1%COLOR_RESET% (between !HOSTONLY_SUBNET![2-100], default is %COLOR_BRIGHTYELLOW%!VM_IP1!%COLOR_RESET%):
if not "!--ip1!"=="" set VM_IP1=!--ip1!

echo.
set /p --ip2=Enter %COLOR_BRIGHTCYAN%IP 2%COLOR_RESET% (between !HOSTONLY_SUBNET![2-100], default is %COLOR_BRIGHTYELLOW%!VM_IP2!%COLOR_RESET%):
if not "!--ip2!"=="" set VM_IP2=!--ip2!

:: Username
echo.
set /p --user=Enter %COLOR_BRIGHTCYAN%Username%COLOR_RESET% (default is '%COLOR_BRIGHTYELLOW%%VM_USER%%COLOR_RESET%'):
if not "!--user!"=="" set VM_USER=!--user!

:: Password
echo.
set /p --password=Enter %COLOR_BRIGHTCYAN%Password%COLOR_RESET% (default is '%COLOR_BRIGHTYELLOW%osboxes.org%COLOR_RESET%'):
if not "!--password!"=="" set VM_USER=!--password!
