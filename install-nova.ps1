# Nova Shield - Windows PowerShell Installer
# Users can right-click and "Run with PowerShell" to install Nova Shield

Write-Host "🛡️ Nova Shield - Windows PowerShell Installer" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📥 Downloading Nova Shield installer..." -ForegroundColor Yellow
Write-Host ""

try {
    # Download the installer script
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ceobitch/codex/main/install-nova.sh" -OutFile "install-nova.sh"
    
    Write-Host "✅ Download complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔧 Installing Nova Shield..." -ForegroundColor Yellow
    Write-Host ""
    
    # Check if bash is available (Git for Windows)
    $bashPath = Get-Command bash -ErrorAction SilentlyContinue
    if ($bashPath) {
        & bash install-nova.sh
    } else {
        Write-Host "❌ Bash not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Please install Git for Windows from: https://git-scm.com/download/win" -ForegroundColor Yellow
        Write-Host "   Then run this installer again" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to close"
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ Installation complete!" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "❌ Failed to download installer" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Please make sure you have internet connection" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
