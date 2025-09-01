@echo off
chcp 65001 >nul

echo 🛡️ Nova Shield - Windows Installer
echo ================================
echo.

echo 📥 Downloading Nova Shield installer...
echo.

REM Download the installer script
curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh -o install-nova.sh

REM Check if curl was successful
if %errorlevel% neq 0 (
    echo ❌ Failed to download installer
    echo.
    echo 💡 Please make sure you have internet connection
    echo.
    pause
    exit /b 1
)

echo ✅ Download complete!
echo.
echo 🔧 Installing Nova Shield...
echo.

REM Run the installer using Git Bash or WSL if available
where bash >nul 2>&1
if %errorlevel% equ 0 (
    bash install-nova.sh
) else (
    echo ❌ Bash not found
    echo.
    echo 💡 Please install Git for Windows from: https://git-scm.com/download/win
    echo    Then run this installer again
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Installation complete!
echo.
echo Press any key to close this window...
pause >nul
