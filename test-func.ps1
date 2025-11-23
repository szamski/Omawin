
function Show-Menu {
    Clear-Host
    $menuText = @"

    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║          Windows 11 Automated Setup Script               ║
    ║          Opinionated & Optimized                         ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝

"@
    Write-ColorOutput $menuText "Cyan"

    Write-ColorOutput "Select Installation Mode:" "White"
    Write-ColorOutput ""
    Write-ColorOutput "  1. Full Installation (Recommended)" "Green"
    Write-ColorOutput "     Install everything: software, drivers, WSL, and configure system" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "  2. Dry-Run Mode (Preview Only)" "Cyan"
    Write-ColorOutput "     See what would be installed without making changes" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "  3. Custom Installation" "Yellow"
    Write-ColorOutput "     Choose which components to install" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "  4. Quick Install (Skip Drivers & WSL)" "Magenta"
    Write-ColorOutput "     Install software and configure system only" "Gray"
    Write-ColorOutput ""
    Write-ColorOutput "  Q. Quit" "Red"
    Write-ColorOutput ""

    $choice = Read-Host "Enter your choice (1-4, Q)"
    return $choice
}

