@echo off
setlocal enabledelayedexpansion

:: set global values
set "APP_PATH=%~dp0" 
set "WORK_PATH=%TEMP%\vbox_%RANDOM%%RANDOM%"
set "VBOX_PATH=%HOMEDRIVE%%HOMEPATH%\VirtualBox VMs"

:: define color display
call "%APP_PATH%\modules\color.bat"

:: get vbox environment
call "%APP_PATH%\modules\env.bat"

:: set default values
set "RAW_URL=https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.vmdk"
set "IMG_FILE=ubuntu-22.04-server-cloudimg-amd64"
set "VM_NAME=VM%RANDOM%"
set VM_MEMORY=512
set VM_CPUS=1
set "VM_USER=osboxes"
set "VM_PASSWORD=osboxes.org"
set "VM_PASSWORD=$6$yC7ks/aneTdlBeSA$nSaS782rM.Ln1JY8KTfSioNwXR.zxpsawhZIAYYx7Wy6v7VneRKZwduar9Dv5bhBhwpHUMAM2svCP2NsGg8aa."
set /a VM_IP1=%RANDOM% %% 100
set "VM_IP1=!HOSTONLY_SUBNET!%VM_IP1%/24"
set /a VM_IP2=%RANDOM% %% 100
set "VM_IP2=!HOSTONLY_SUBNET!%VM_IP2%/32"

:: loop through all arguments
for %%n in (%*) do (
  set args=%%n
  set sign=!args:~0,1!
  
  if "!sign!"=="-" (
    set "arg=!args!"
    set "!arg!=!arg!"
  ) else (
    set "!arg!=!args!"
  )
)

:: url
if not "%-l%"=="" set "RAW_URL=%-l%"
if not "%--url%"=="" set "RAW_URL=%--url%"

:: vm name
if not "%-n%"=="" set "VM_NAME=%-n%"
if not "%--name%"=="" set "VM_NAME=%--name%"

:: vm os
if not "%-o%"=="" set "IMG_FILE=%-o%"
if not "%--os%"=="" set "IMG_FILE=%--os%"

:: vm cpus
if not "%-c%"=="" set VM_CPUS=%-c%
if not "%--cpu%"=="" set VM_CPUS=%--cpu%
if not "%--cpus%"=="" set VM_CPUS=%--cpus%

:: vm memory
if not "%-m%"=="" set VM_MEMORY=%-m%
if not "%--ram%"=="" set VM_MEMORY=%--ram%
if not "%--mem%"=="" set VM_MEMORY=%--mem%
if not "%--mems%"=="" set VM_MEMORY=%--mems%
if not "%--memory%"=="" set VM_MEMORY=%--memory%
if not "%--memories%"=="" set VM_MEMORY=%--memories%

:: vm user
if not "%-u%"=="" set VM_USER=%-u%
if not "%--user%"=="" set VM_USER=%--user%
if not "%--username%"=="" set VM_USER=%--username%

:: vm password
if not "%-p%"=="" set VM_PASSWORD=%-p%
if not "%--password%"=="" set VM_PASSWORD=%--user%

:: interactive
if not "%-i%"=="" set IS_INTERACTIVE=%-i%
if not "%--interactive%"=="" set IS_INTERACTIVE=%--interactive%

:: help
if "%~1"=="" set IS_HELP=--help
if not "%-h%"=="" set IS_HELP=%-h%
if not "%--help%"=="" set IS_HELP=%--help%

:: display help
if not "%IS_HELP%"=="" (
  echo Usage: %0 [options]
  echo Options:
  echo  -n or --name value	VM name.
  echo  -o or --os value        VM operating system.
  echo  -c or --cpus value	VM cpus.
  echo  -m or --memory value	VM memory in Megabyte.
  echo  -u or --username	VM user name.
  echo  -p or --password	VM password.
  echo  --ip or --ip1           VM IP
  echo  --ip2                   VM secondary IP
  echo  --update                Update this app to latest
  echo Example: %0 -n vmname --os "%IMG_FILE%" -p 2 -m 2048 --ip !HOSTONLY_SUBNET!10/24
  goto :eof
)

:: update
if not "%--update%"=="" (
  git pull
  goto :eof
)

: display interactive
if not "%IS_INTERACTIVE%"=="" call "%APP_PATH%\modules\menu.bat"

set "VM_PATH=%VBOX_PATH%\%VM_NAME%"
if exist "%VM_PATH%" goto :eof

mkdir "%VM_PATH%"

:: create image
call "%APP_PATH%\modules\image.bat"

set "IMG_PATH=%VBOX_PATH%\!IMG_FILE!!IMG_EXT!"

:: create cloud-init iso
call "%APP_PATH%\modules\cloudinit.bat"

:: create VM
call "%APP_PATH%\modules\vmcreate.bat"
