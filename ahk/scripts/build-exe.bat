@echo off
chcp 65001 >nul
echo Building Smart Paste v0.3 EXE...
echo.

REM Check if Ahk2Exe exists
if not exist "C:\Program Files\AutoHotkey\v2\Compiler\Ahk2Exe.exe" (
    echo Error: Ahk2Exe not found!
    echo Please install AutoHotkey v2 with compiler.
    pause
    exit /b 1
)

REM Create output directory
if not exist "..\release" mkdir "..\release"

REM Build EXE
echo Compiling SmartPaste.ahk to EXE...
"C:\Program Files\AutoHotkey\v2\Compiler\Ahk2Exe.exe" ^
    /in "..\SmartPaste.ahk" ^
    /out "..\release\SmartPaste-v0.3.exe" ^
    /compress 1

if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build completed successfully!
echo Output: release\SmartPaste-v0.3.exe
echo.
pause
