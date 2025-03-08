@echo off
:: setlocal EnableDelayedExpansion


:: image https://drive.google.com/file/d/1mFpKwjvcmqCLrNsTIvunuGB059r7SzGd/view?usp=sharing

set "line=0"

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

        :: Extract image filename
        for %%a in ("!RAW_URL!") do (
          set "RAW_FILE=%%~nxa"
        )

        :: Extract image basename
        for %%F in ("!RAW_FILE!") do (
          set "RAW_FILE=%%~nF"
          set "RAW_EXT=%%~xF"
        )

        if "!RAW_FILE!"=="%IMG_FILE%" (
          if "%IMG_URL%"=="" set "IMG_URL=!RAW_URL!"
          if "%IMG_EXT%"=="" set "IMG_EXT=!RAW_EXT!"
          if "%IMG_OSTYPE%"=="" set "IMG_OSTYPE=!RAW_OSTYPE!"
        )
      )
    )
  )
)

set "IMG_PATH=%VBOX_PATH%\!IMG_FILE!!IMG_EXT!"

:: handling QCOW file
if "!IMG_EXT!"==".qcow2" (
  :: get qemu for windows
  if not exist "%TEMP%\qemu-img.exe" (
    set "FILE_ZIP=qemu-img-win-x64-2_3_0.zip"

    if not exist "%TEMP%\!FILE_ZIP!" (
      echo %COLOR_BRIGHTCYAN%--^> Download Qemu%COLOR_RESET% "https://cloudbase.it/downloads/!FILE_ZIP!"
      curl -L -o "%TEMP%\!FILE_ZIP!" "https://cloudbase.it/downloads/!FILE_ZIP!"
    )

    cd %TEMP%
    tar -xvf "%TEMP%\!FILE_ZIP!"
    
    set FILE_ZIP=
    cd %APP_PATH%
  )

  %TEMP%\qemu-img.exe convert ^
                      -f qcow2 ^
                      -O vmdk ^
                      "%VBOX_PATH%\%IMG_FILE%%IMG_EXT%" ^
                      "%VBOX_PATH%\%IMG_FILE%.vmdk"
)

:: handle OVA file
if "!IMG_EXT!"==".ova" (
  if not exist "%TEMP%\%IMG_FILE%%IMG_EXT%" (
    echo %COLOR_BRIGHTCYAN%--^> Download Image%COLOR_RESET% !IMG_URL!
    curl -L -o "%TEMP%\%IMG_FILE%%IMG_EXT%" "!IMG_URL!"
  )

  set "IMG_TEMP=%TEMP%\ova%RANDOM%%RANDOM%"
  mkdir "!IMG_TEMP!"
  cd "!IMG_TEMP!"
  
  tar -xvf "%TEMP%\%IMG_FILE%%IMG_EXT%"

  :: rename vmdk file inside ova
  for %%f in (*.vmdk) do (
    move %%f "%VBOX_PATH%\%IMG_FILE%.vmdk"
  )

  set "IMG_EXT=.vmdk"

  cd %APP_PATH%
  rmdir /s /q "!IMG_TEMP!"
)

:: get netboot
if not exist "%TEMP%\netboot.xyz.iso" (
  echo %COLOR_BRIGHTCYAN%--^> Download Netboot%COLOR_RESET% "https://netboot.xyz/ipxe/netboot.xyz.iso"
  curl -L -o "%TEMP%\netboot.xyz.iso" "https://netboot.xyz/ipxe/netboot.xyz.iso"
)

set RAW_URL=
set RAW_FILE=
set RAW_EXT=
set RAW_OSTYPE=
