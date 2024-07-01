@ECHO OFF

::--------------------------------------------------------------------------
set "name=ZCL_ZombieEscape2"
set "version=beta10"

set /A "delump=0"

set /A "verbose=1"
::--------------------------------------------------------------------------

set /A "e=0"
SET "root=%~dp0"

set "pk3=%name%-%version%.pk3"

:: call :sub >pk3_output.log
:: exit /b

: :sub

if %verbose% == 1 (
echo Current directory: "%root%"
echo pk3 location: "%root%\bin\%pk3%"
echo /src directory: "%root%src\"
echo /tools directory: "%root%tools\"
)

if %delump% == 0 goto carryon
pushd "%root%src\"
echo Removing .lmp extension from files in "%cd%"...
forfiles /S /M *.lmp /C "cmd /c rename @file @fname"

:carryon
echo Testing for 7zip...
pushd "%root%tools\"
if %verbose% == 1 echo Working directory: "%cd%"
7za.exe /?  2> NUL
IF %ERRORLEVEL%==9009 ECHO 7za.exe doesn't exist in $cd$ && set /A "e=1"

if %e% == 1 goto eof


::--------------------------------------------------------------------------

echo Packing "%root%src\" into "%root%\bin\%pk3%" ...
7za.exe u -tzip "%root%\bin\%pk3%" -r "%root%src\*" -mx5 -up0q0r2x1y2z1


echo Reordering TEXTURES files...
if %verbose% == 1 echo Working directory: "%cd%"
if exist textures.txt del textures.txt
7za x "%root%\bin\%pk3%" TEXTURES.* -y
7za d "%root%\bin\%pk3%" TEXTURES.*
forfiles /M TEXTURES.* /C "cmd /c rename @file abc@file"
7za a "%root%\bin\%pk3%" abcTEXTURES.*
del /f abcTEXTURES.*
pushd "%root%src\"
if %verbose% == 1 echo Working directory: "%cd%"
for /f %%i in ('FORFILES /M TEXTURES.* /C "cmd /c echo @file"') do @echo abc%%~i >> "%root%tools\textures.txt" && @echo %%~i >> "%root%tools\textures.txt"
pushd "%root%tools\"
if %verbose% == 1 echo Working directory: "%cd%"
7za rn "%root%\bin\%pk3%" @textures.txt
del textures.txt

echo Done!
exit /B

:eof
