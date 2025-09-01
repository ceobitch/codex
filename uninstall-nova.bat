@echo off
chcp 65001 >nul

echo 🛡️ Uninstalling Nova Shield...
echo ==============================
echo.

echo 🔄 Stopping Nova Shield processes...
taskkill /f /im nova.exe 2>nul
taskkill /f /im codex-tui.exe 2>nul

echo 📦 Uninstalling npm package...
npm uninstall -g nova-shield 2>nul

echo 🗑️ Removing Nova Shield files...
if exist "%USERPROFILE%\.nova-shield" (
    rmdir /s /q "%USERPROFILE%\.nova-shield"
    echo ✅ Nova Shield files removed
) else (
    echo ❌ Nova Shield not found
)

echo.
echo 🎉 Nova Shield uninstalled successfully!
echo.
echo 💡 To reinstall, run:
echo    curl -fsSL https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh ^| bash
echo.
pause
