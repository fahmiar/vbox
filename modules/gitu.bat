@echo off
:: setlocal EnableDelayedExpansion

set "GIT_ZIP=PortableGit-2.48.1-64-bit.7z.exe"
set "GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/%GIT_ZIP%"

if not exist "%TEMP%\PortableGit" (
  if not exist "%TEMP%\%GIT_ZIP%" (
    echo %COLOR_BRIGHTCYAN%--^> Download Git%COLOR_RESET% "%GIT_URL%"
    curl -L -o "%TEMP%\%GIT_ZIP%" "%GIT_URL%"
  )

  :: install git
  "%TEMP%\%GIT_ZIP%" -y
)

set GIT_ZIP=
set GIT_URL=
set "GIT_PATH=%TEMP%\PortableGit\cmd\git.exe"

cd %APP_PATH%
"%GIT_PATH%" pull