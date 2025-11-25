<#
.SYNOPSIS
    Installs Nerd Fonts for terminal usage.

.DESCRIPTION
    Installs CaskaydiaCove Nerd Font (Cascadia Code with icons) via winget.
    This font is essential for proper Starship prompt display.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\install-fonts.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-FontInstalled {
    param([string]$FontName)

    try {
        $fonts = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
        $fontInstalled = $fonts.PSObject.Properties | Where-Object { $_.Value -like "*$FontName*" }
        return ($null -ne $fontInstalled)
    }
    catch {
        return $false
    }
}

function Install-NerdFont {
    param(
        [string]$FontId,
        [string]$FontName
    )

    Write-ColorOutput "`nInstalling $FontName..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install font: $FontName ($FontId)"
        return $true
    }

    try {
        # Check if font is already installed (basic check)
        if (Test-FontInstalled -FontName "CaskaydiaCove") {
            Write-ColorOutput "  ○ CaskaydiaCove Nerd Font appears to be already installed" "Gray"
            return $true
        }

        # Install via winget
        Write-ColorOutput "  Installing via winget..." "Gray"
        winget install --id $FontId --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ $FontName installed successfully" "Green"
            Write-ColorOutput "  Note: You may need to restart applications to see the new font" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  ✗ Failed to install $FontName (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  ✗ Error installing $FontName : $(<#
.SYNOPSIS
    Installs Nerd Fonts for terminal usage.

.DESCRIPTION
    Installs CaskaydiaCove Nerd Font (Cascadia Code with icons) via winget.
    This font is essential for proper Starship prompt display.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\install-fonts.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-FontInstalled {
    param([string]$FontName)

    try {
        $fonts = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
        $fontInstalled = $fonts.PSObject.Properties | Where-Object { $_.Value -like "*$FontName*" }
        return ($null -ne $fontInstalled)
    }
    catch {
        return $false
    }
}

function Install-NerdFont {
    param(
        [string]$FontId,
        [string]$FontName
    )

    Write-ColorOutput "`nInstalling $FontName..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install font: $FontName ($FontId)"
        return $true
    }

    try {
        # Check if font is already installed (basic check)
        if (Test-FontInstalled -FontName "CaskaydiaCove") {
            Write-ColorOutput "  ○ CaskaydiaCove Nerd Font appears to be already installed" "Gray"
            return $true
        }

        # Install via winget
        Write-ColorOutput "  Installing via winget..." "Gray"
        winget install --id $FontId --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ $FontName installed successfully" "Green"
            Write-ColorOutput "  Note: You may need to restart applications to see the new font" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  ✗ Failed to install $FontName (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  ✗ Error installing $FontName : $_" "Red"
        return $false
    }
}

function Set-WindowsTerminalFont {
    Write-ColorOutput "`nConfiguring Windows Terminal to use CaskaydiaCove..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Update Windows Terminal settings.json to use CaskaydiaCove NF"
        return $true
    }

    try {
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

        if (-not (Test-Path $settingsPath)) {
            Write-ColorOutput "  ○ Windows Terminal settings not found (not installed or not run yet)" "Gray"
            return $true
        }

        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        # Update default profile font
        if (-not $settings.profiles.defaults) {
            $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{} -Force
        }

        if (-not $settings.profiles.defaults.font) {
            $settings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{} -Force
        }

        $settings.profiles.defaults.font.face = "CaskaydiaCove Nerd Font"

        # Save settings
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

        Write-ColorOutput "  ✓ Windows Terminal configured to use CaskaydiaCove Nerd Font" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  ✗ Failed to configure Windows Terminal: $_" "Red"
        Write-ColorOutput "  You can manually set the font in Windows Terminal settings" "Yellow"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Nerd Fonts Installation" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalSteps = 0

# ========================================
# Step 1: Install CaskaydiaCove Nerd Font
# ========================================
Write-ColorOutput "`n[Step 1: CaskaydiaCove Nerd Font]" "Cyan"
$totalSteps++

if (Install-NerdFont -FontId "DEVCOM.CascadiaCodeNerdFont" -FontName "CaskaydiaCove Nerd Font") {
    $successCount++
}

# ========================================
# Step 2: Configure Windows Terminal
# ========================================
Write-ColorOutput "`n[Step 2: Windows Terminal Configuration]" "Cyan"
$totalSteps++

if (Set-WindowsTerminalFont) {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Font Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nFont installation completed successfully!" "Green"
}
else {
    Write-ColorOutput "`nFont installation completed with some warnings." "Yellow"
}

Write-ColorOutput "`n[Important Notes]" "Cyan"
Write-ColorOutput "  • The font is now installed system-wide" "Gray"
Write-ColorOutput "  • Restart Windows Terminal if it's currently open" "Gray"
Write-ColorOutput "  • The font enables icons in Starship prompt" "Gray"
Write-ColorOutput "  • You can select it in any terminal: 'CaskaydiaCove Nerd Font'" "Gray"
.Exception.Message)" "Red"
        return $false
    }
}

function Set-WindowsTerminalFont {
    Write-ColorOutput "`nConfiguring Windows Terminal to use CaskaydiaCove..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Update Windows Terminal settings.json to use CaskaydiaCove NF"
        return $true
    }

    try {
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

        if (-not (Test-Path $settingsPath)) {
            Write-ColorOutput "  ○ Windows Terminal settings not found (not installed or not run yet)" "Gray"
            return $true
        }

        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        # Update default profile font
        if (-not $settings.profiles.defaults) {
            $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{} -Force
        }

        if (-not $settings.profiles.defaults.font) {
            $settings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{} -Force
        }

        $settings.profiles.defaults.font.face = "CaskaydiaCove Nerd Font"

        # Save settings
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

        Write-ColorOutput "  ✓ Windows Terminal configured to use CaskaydiaCove Nerd Font" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  ✗ Failed to configure Windows Terminal: $(<#
.SYNOPSIS
    Installs Nerd Fonts for terminal usage.

.DESCRIPTION
    Installs CaskaydiaCove Nerd Font (Cascadia Code with icons) via winget.
    This font is essential for proper Starship prompt display.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\install-fonts.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-FontInstalled {
    param([string]$FontName)

    try {
        $fonts = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
        $fontInstalled = $fonts.PSObject.Properties | Where-Object { $_.Value -like "*$FontName*" }
        return ($null -ne $fontInstalled)
    }
    catch {
        return $false
    }
}

function Install-NerdFont {
    param(
        [string]$FontId,
        [string]$FontName
    )

    Write-ColorOutput "`nInstalling $FontName..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install font: $FontName ($FontId)"
        return $true
    }

    try {
        # Check if font is already installed (basic check)
        if (Test-FontInstalled -FontName "CaskaydiaCove") {
            Write-ColorOutput "  ○ CaskaydiaCove Nerd Font appears to be already installed" "Gray"
            return $true
        }

        # Install via winget
        Write-ColorOutput "  Installing via winget..." "Gray"
        winget install --id $FontId --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ $FontName installed successfully" "Green"
            Write-ColorOutput "  Note: You may need to restart applications to see the new font" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  ✗ Failed to install $FontName (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  ✗ Error installing $FontName : $_" "Red"
        return $false
    }
}

function Set-WindowsTerminalFont {
    Write-ColorOutput "`nConfiguring Windows Terminal to use CaskaydiaCove..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Update Windows Terminal settings.json to use CaskaydiaCove NF"
        return $true
    }

    try {
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

        if (-not (Test-Path $settingsPath)) {
            Write-ColorOutput "  ○ Windows Terminal settings not found (not installed or not run yet)" "Gray"
            return $true
        }

        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        # Update default profile font
        if (-not $settings.profiles.defaults) {
            $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{} -Force
        }

        if (-not $settings.profiles.defaults.font) {
            $settings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{} -Force
        }

        $settings.profiles.defaults.font.face = "CaskaydiaCove Nerd Font"

        # Save settings
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

        Write-ColorOutput "  ✓ Windows Terminal configured to use CaskaydiaCove Nerd Font" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  ✗ Failed to configure Windows Terminal: $_" "Red"
        Write-ColorOutput "  You can manually set the font in Windows Terminal settings" "Yellow"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Nerd Fonts Installation" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalSteps = 0

# ========================================
# Step 1: Install CaskaydiaCove Nerd Font
# ========================================
Write-ColorOutput "`n[Step 1: CaskaydiaCove Nerd Font]" "Cyan"
$totalSteps++

if (Install-NerdFont -FontId "DEVCOM.CascadiaCodeNerdFont" -FontName "CaskaydiaCove Nerd Font") {
    $successCount++
}

# ========================================
# Step 2: Configure Windows Terminal
# ========================================
Write-ColorOutput "`n[Step 2: Windows Terminal Configuration]" "Cyan"
$totalSteps++

if (Set-WindowsTerminalFont) {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Font Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nFont installation completed successfully!" "Green"
}
else {
    Write-ColorOutput "`nFont installation completed with some warnings." "Yellow"
}

Write-ColorOutput "`n[Important Notes]" "Cyan"
Write-ColorOutput "  • The font is now installed system-wide" "Gray"
Write-ColorOutput "  • Restart Windows Terminal if it's currently open" "Gray"
Write-ColorOutput "  • The font enables icons in Starship prompt" "Gray"
Write-ColorOutput "  • You can select it in any terminal: 'CaskaydiaCove Nerd Font'" "Gray"
.Exception.Message)" "Red"
        Write-ColorOutput "  You can manually set the font in Windows Terminal settings" "Yellow"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Nerd Fonts Installation" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalSteps = 0

# ========================================
# Step 1: Install CaskaydiaCove Nerd Font
# ========================================
Write-ColorOutput "`n[Step 1: CaskaydiaCove Nerd Font]" "Cyan"
$totalSteps++

if (Install-NerdFont -FontId "DEVCOM.CascadiaCodeNerdFont" -FontName "CaskaydiaCove Nerd Font") {
    $successCount++
}

# ========================================
# Step 2: Configure Windows Terminal
# ========================================
Write-ColorOutput "`n[Step 2: Windows Terminal Configuration]" "Cyan"
$totalSteps++

if (Set-WindowsTerminalFont) {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Font Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nFont installation completed successfully!" "Green"
}
else {
    Write-ColorOutput "`nFont installation completed with some warnings." "Yellow"
}

Write-ColorOutput "`n[Important Notes]" "Cyan"
Write-ColorOutput "  • The font is now installed system-wide" "Gray"
Write-ColorOutput "  • Restart Windows Terminal if it's currently open" "Gray"
Write-ColorOutput "  • The font enables icons in Starship prompt" "Gray"
Write-ColorOutput "  • You can select it in any terminal: 'CaskaydiaCove Nerd Font'" "Gray"

