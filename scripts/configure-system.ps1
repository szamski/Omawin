# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Configures Windows 11 system settings to personal preferences.

.DESCRIPTION
    Modifies Windows registry settings to customize Explorer, taskbar, theme, and privacy settings.
    All settings are based on the current system configuration analysis.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\configure-system.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord",
        [string]$Description
    )

    if (Test-DryRun) {
        Write-DryRunAction "Set registry: $Path\$Name = $Value ($Type) - $Description"
        return $true
    }

    try {
        # Create registry path if it doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        # Set the registry value
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
        Write-ColorOutput "  + $Description" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  X Failed to set $Description : $_" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Windows System Configuration" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalSettings = 0

# ========================================
# Windows Explorer Settings
# ========================================
Write-ColorOutput "`n[Explorer Settings]" "Cyan"
$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "Hidden" -Value 1 -Type "DWord" `
        -Description "Show hidden files and folders") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "HideFileExt" -Value 0 -Type "DWord" `
        -Description "Show file extensions") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "ShowSuperHidden" -Value 0 -Type "DWord" `
        -Description "Hide super hidden system files") {
    $successCount++
}

# ========================================
# Theme Settings (Dark Mode)
# ========================================
Write-ColorOutput "`n[Theme Settings]" "Cyan"
$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
        -Name "AppsUseLightTheme" -Value 0 -Type "DWord" `
        -Description "Enable dark mode for apps") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
        -Name "SystemUsesLightTheme" -Value 0 -Type "DWord" `
        -Description "Enable dark mode for system") {
    $successCount++
}

# ========================================
# Taskbar Settings
# ========================================
Write-ColorOutput "`n[Taskbar Settings]" "Cyan"
$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
        -Name "SearchboxTaskbarMode" -Value 0 -Type "DWord" `
        -Description "Hide search box from taskbar") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "ShowTaskViewButton" -Value 0 -Type "DWord" `
        -Description "Hide Task View button") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "TaskbarAnimations" -Value 0 -Type "DWord" `
        -Description "Disable taskbar animations") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "DisablePreviewDesktop" -Value 1 -Type "DWord" `
        -Description "Disable desktop preview on hover") {
    $successCount++
}

# ========================================
# Privacy and Start Menu Settings
# ========================================
Write-ColorOutput "`n[Privacy and Start Menu Settings]" "Cyan"
$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "Start_TrackDocs" -Value 0 -Type "DWord" `
        -Description "Disable recent documents tracking") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "Start_IrisRecommendations" -Value 0 -Type "DWord" `
        -Description "Disable Start Menu recommendations") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "Start_AccountNotifications" -Value 0 -Type "DWord" `
        -Description "Disable Start Menu account notifications") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "Start_RecoPersonalizedSites" -Value 0 -Type "DWord" `
        -Description "Disable personalized sites in Start Menu") {
    $successCount++
}

# ========================================
# Performance Settings
# ========================================
Write-ColorOutput "`n[Performance Settings]" "Cyan"
$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Control Panel\Desktop\WindowMetrics" `
        -Name "MinAnimate" -Value 0 -Type "String" `
        -Description "Disable window animations") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" `
        -Name "UserPreferencesMask" -Value ([byte[]](0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00)) -Type "Binary" `
        -Description "Optimize visual effects for performance") {
    $successCount++
}

# ========================================
# Additional Explorer Settings
# ========================================
Write-ColorOutput "`n[Additional Explorer Settings]" "Cyan"
$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "LaunchTo" -Value 1 -Type "DWord" `
        -Description "Open Explorer to 'This PC' instead of Quick Access") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "SharingWizardOn" -Value 0 -Type "DWord" `
        -Description "Disable sharing wizard") {
    $successCount++
}

# ========================================
# Restart Explorer
# ========================================
Write-ColorOutput "`n[Applying Changes]" "Cyan"
if (Test-DryRun) {
    Write-DryRunAction "Restart Windows Explorer to apply changes"
}
else {
    try {
        Write-ColorOutput "  Restarting Windows Explorer to apply changes..." "Yellow"
        Stop-Process -Name explorer -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        Write-ColorOutput "  + Explorer restarted successfully" "Green"
    }
    catch {
        Write-ColorOutput "  X Failed to restart Explorer: $_" "Red"
        Write-ColorOutput "  Please restart Explorer manually or log off/on for changes to take effect" "Yellow"
    }
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Configuration Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total settings: $totalSettings" "White"
Write-ColorOutput "Successfully applied: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSettings - $successCount)" "Red"

if ($successCount -eq $totalSettings) {
    Write-ColorOutput "`nAll system settings configured successfully!" "Green"
}
else {
    Write-ColorOutput "`nSome settings could not be applied. Please check the errors above." "Yellow"
}

Write-ColorOutput "`nNote: Some changes may require a system restart to take full effect." "Yellow"
