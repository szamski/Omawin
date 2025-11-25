# Note: Administrator privileges required for most operations
# #Requires -RunAsAdministrator is commented to allow remote execution (irm | iex)

<#
.SYNOPSIS
    Automated Windows 11 setup script - One script to rule them all!

.DESCRIPTION
    This is the main orchestration script that sets up a fresh Windows 11 installation with:
    - Essential software installation via winget
    - Custom system settings and preferences
    - Environment variables and PATH configuration
    - Hardware detection and driver installation
    - Windows Subsystem for Linux (WSL)

    This script is designed to be run immediately after a fresh Windows 11 installation.

.PARAMETER SkipSoftware
    Skip software installation

.PARAMETER SkipSystemConfig
    Skip system configuration

.PARAMETER SkipEnvironment
    Skip environment variables setup

.PARAMETER SkipDrivers
    Skip hardware detection and driver installation

.PARAMETER SkipWSL
    Skip WSL installation

.PARAMETER SkipTelemetry
    Skip disabling telemetry and privacy tracking

.PARAMETER SkipPowerShell
    Skip PowerShell profile configuration

.PARAMETER DryRun
    Run in dry-run mode - shows what would be done without making any changes

.EXAMPLE
    .\setup.ps1
    Run full setup (recommended)

.EXAMPLE
    .\setup.ps1 -SkipWSL
    Run setup but skip WSL installation

.EXAMPLE
    .\setup.ps1 -DryRun
    Preview what the script would do without making any changes

.NOTES
    Author: Generated with Claude Code
    Requires: Windows 11, PowerShell 5.1+, Administrator privileges
#>

param(
    [switch]$SkipSoftware,
    [switch]$SkipSystemConfig,
    [switch]$SkipEnvironment,
    [switch]$SkipDrivers,
    [switch]$SkipWSL,
    [switch]$SkipTelemetry,
    [switch]$SkipPowerShell,
    [switch]$SkipGitConfig,
    [switch]$DryRun,
    [switch]$NoMenu
)

# ========================================
# Configuration
# ========================================
$ErrorActionPreference = "Continue"

# Handle both local file execution and remote execution (irm | iex)
$ScriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $env:TEMP }
$LogFile = if ($PSScriptRoot) {
    Join-Path $ScriptRoot "setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
} else {
    Join-Path $env:TEMP "opinionated-windows11-setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
}

# Set global dry-run flag for child scripts
if ($DryRun) {
    $env:DRYRUN_MODE = "true"
}

# ========================================
# Handle Remote Execution (irm | iex)
# ========================================
# If script is running from memory (via irm | iex), clone the repository first
if (-not $PSScriptRoot) {
    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host "  Remote Installation Detected" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "`nThe script is running remotely. Downloading repository..." -ForegroundColor Yellow

    $repoUrl = "https://github.com/szamski/opinionated_windows11"
    $targetDir = Join-Path $env:USERPROFILE "opinionated_windows11"

    # Check if git is available
    try {
        $null = git --version 2>&1
        $gitAvailable = $LASTEXITCODE -eq 0
    }
    catch {
        $gitAvailable = $false
    }

    if ($gitAvailable) {
        Write-Host "Cloning repository to: $targetDir" -ForegroundColor Cyan

        # Remove existing directory if present
        if (Test-Path $targetDir) {
            Write-Host "Removing existing directory..." -ForegroundColor Yellow
            Remove-Item -Path $targetDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        # Clone the repository (explicitly use main branch)
        git clone --branch main $repoUrl $targetDir 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Repository cloned successfully!" -ForegroundColor Green
            Write-Host "`nLaunching setup script..." -ForegroundColor Cyan
            Write-Host ""

            # Build the command with all current parameters
            $paramString = @()
            if ($SkipSoftware) { $paramString += "-SkipSoftware" }
            if ($SkipSystemConfig) { $paramString += "-SkipSystemConfig" }
            if ($SkipEnvironment) { $paramString += "-SkipEnvironment" }
            if ($SkipDrivers) { $paramString += "-SkipDrivers" }
            if ($SkipWSL) { $paramString += "-SkipWSL" }
            if ($SkipTelemetry) { $paramString += "-SkipTelemetry" }
            if ($SkipPowerShell) { $paramString += "-SkipPowerShell" }
            if ($DryRun) { $paramString += "-DryRun" }
            if ($NoMenu) { $paramString += "-NoMenu" }

            $scriptPath = Join-Path $targetDir "setup.ps1"
            $params = $paramString -join " "

            # Build PowerShell command
            $psCommand = "Set-Location '$targetDir'; & '$scriptPath' $params"

            Write-Host "Opening new PowerShell window (with Administrator privileges)..." -ForegroundColor Yellow
            Write-Host "If UAC prompts, please click 'Yes' to continue." -ForegroundColor Yellow
            Write-Host ""
            Start-Sleep -Seconds 2

            # Launch new PowerShell window with admin privileges
            $startProcessParams = @{
                FilePath = "powershell.exe"
                ArgumentList = @("-NoExit", "-ExecutionPolicy", "Bypass", "-Command", $psCommand)
                Verb = "RunAs"
            }

            try {
                Start-Process @startProcessParams
                Write-Host "New window launched successfully!" -ForegroundColor Green
                Write-Host "You can close this window." -ForegroundColor Gray
                Start-Sleep -Seconds 3
                exit 0
            }
            catch {
                Write-Host "Failed to launch with administrator privileges: $_" -ForegroundColor Red
                Write-Host "`nPlease run manually:" -ForegroundColor Yellow
                Write-Host "  cd $targetDir" -ForegroundColor Cyan
                Write-Host "  .\setup.ps1" -ForegroundColor Cyan
                Read-Host "`nPress Enter to exit"
                exit 1
            }
        }
        else {
            Write-Host "Failed to clone repository!" -ForegroundColor Red
            Write-Host "Please clone manually: git clone $repoUrl" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "Git is not installed!" -ForegroundColor Red
        Write-Host "`nPlease either:" -ForegroundColor Yellow
        Write-Host "  1. Install git first, then run this command again" -ForegroundColor White
        Write-Host "  2. Or manually clone: git clone $repoUrl" -ForegroundColor White
        Write-Host "     Then run: cd opinionated_windows11; .\setup.ps1" -ForegroundColor White
        exit 1
    }
}

# ========================================
# Helper Functions
# ========================================
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message"

    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $logMessage
}

function Write-Header {
    param([string]$Title)

    $line = "=" * 60
    Write-ColorOutput "`n$line" "Magenta"
    Write-ColorOutput "  $Title" "Magenta"
    Write-ColorOutput "$line" "Magenta"
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-ScriptModule {
    param(
        [string]$ModulePath,
        [string]$ModuleName,
        [string]$Description
    )

    Write-Header $Description

    if (-not (Test-Path $ModulePath)) {
        Write-ColorOutput "Error: Module not found at $ModulePath" "Red"
        return $false
    }

    try {
        Write-ColorOutput "Executing $ModuleName..." "Cyan"
        $startTime = Get-Date

        & $ModulePath

        $duration = (Get-Date) - $startTime
        Write-ColorOutput "`n✓ $ModuleName completed in $($duration.TotalSeconds) seconds" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "`n✗ Error executing $ModuleName : $_" "Red"
        Write-ColorOutput $_.ScriptStackTrace "Red"
        return $false
    }
}

function Show-Menu {
    Clear-Host
    Write-ColorOutput "" "Cyan"
    Write-ColorOutput "    ╔═══════════════════════════════════════════════════════════╗" "Cyan"
    Write-ColorOutput "    ║                                                           ║" "Cyan"
    Write-ColorOutput "    ║          Windows 11 Automated Setup Script               ║" "Cyan"
    Write-ColorOutput "    ║          Opinionated & Optimized                         ║" "Cyan"
    Write-ColorOutput "    ║                                                           ║" "Cyan"
    Write-ColorOutput "    ╚═══════════════════════════════════════════════════════════╝" "Cyan"
    Write-ColorOutput "" "Cyan"

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

function Show-CustomMenu {
    Clear-Host
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    Write-ColorOutput "  Custom Installation Options" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    Write-ColorOutput ""

    $options = @{
        Software = $true
        SystemConfig = $true
        Environment = $true
        Drivers = $true
        WSL = $true
        Telemetry = $true
        PowerShell = $true
        GitConfig = $true
        DryRun = $false
    }

    while ($true) {
        Write-ColorOutput "Select components to install:" "White"
        Write-ColorOutput ""
        Write-ColorOutput "  1. [$(if ($options.Software) { 'X' } else { ' ' })] Software Installation" $(if ($options.Software) { "Green" } else { "Gray" })
        Write-ColorOutput "  2. [$(if ($options.SystemConfig) { 'X' } else { ' ' })] System Configuration" $(if ($options.SystemConfig) { "Green" } else { "Gray" })
        Write-ColorOutput "  3. [$(if ($options.Environment) { 'X' } else { ' ' })] Environment Variables" $(if ($options.Environment) { "Green" } else { "Gray" })
        Write-ColorOutput "  4. [$(if ($options.Drivers) { 'X' } else { ' ' })] Hardware Drivers" $(if ($options.Drivers) { "Green" } else { "Gray" })
        Write-ColorOutput "  5. [$(if ($options.WSL) { 'X' } else { ' ' })] Windows Subsystem for Linux (WSL)" $(if ($options.WSL) { "Green" } else { "Gray" })
        Write-ColorOutput "  6. [$(if ($options.Telemetry) { 'X' } else { ' ' })] Disable Telemetry and Privacy Tracking" $(if ($options.Telemetry) { "Green" } else { "Gray" })
        Write-ColorOutput "  7. [$(if ($options.PowerShell) { 'X' } else { ' ' })] PowerShell Profile (Starship)" $(if ($options.PowerShell) { "Green" } else { "Gray" })
        Write-ColorOutput "  8. [$(if ($options.GitConfig) { 'X' } else { ' ' })] Git and GitHub Configuration" $(if ($options.GitConfig) { "Green" } else { "Gray" })
        Write-ColorOutput ""
        Write-ColorOutput "  D. [$(if ($options.DryRun) { 'X' } else { ' ' })] Dry-Run Mode (Preview Only)" $(if ($options.DryRun) { "Cyan" } else { "Gray" })
        Write-ColorOutput ""
        Write-ColorOutput "  S. Start Installation" "Green"
        Write-ColorOutput "  B. Back to Main Menu" "Yellow"
        Write-ColorOutput ""

        $choice = Read-Host "Toggle option (1-8, D) or Start (S) / Back (B)"

        switch ($choice.ToUpper()) {
            '1' { $options.Software = -not $options.Software }
            '2' { $options.SystemConfig = -not $options.SystemConfig }
            '3' { $options.Environment = -not $options.Environment }
            '4' { $options.Drivers = -not $options.Drivers }
            '5' { $options.WSL = -not $options.WSL }
            '6' { $options.Telemetry = -not $options.Telemetry }
            '7' { $options.PowerShell = -not $options.PowerShell }
            '8' { $options.GitConfig = -not $options.GitConfig }
            'D' { $options.DryRun = -not $options.DryRun }
            'S' { return $options }
            'B' { return $null }
        }

        Clear-Host
        Write-ColorOutput "═══════════════════════════════════════" "Cyan"
        Write-ColorOutput "  Custom Installation Options" "Cyan"
        Write-ColorOutput "═══════════════════════════════════════" "Cyan"
        Write-ColorOutput ""
    }
}

# ========================================
# Interactive Menu (if not running with parameters)
# ========================================
if (-not $NoMenu -and -not $PSBoundParameters.ContainsKey('SkipSoftware') -and
    -not $PSBoundParameters.ContainsKey('SkipSystemConfig') -and
    -not $PSBoundParameters.ContainsKey('SkipEnvironment') -and
    -not $PSBoundParameters.ContainsKey('SkipDrivers') -and
    -not $PSBoundParameters.ContainsKey('SkipWSL') -and
    -not $PSBoundParameters.ContainsKey('DryRun')) {

    $menuChoice = Show-Menu

    switch ($menuChoice) {
        '1' {
            # Full Installation - no changes needed, all defaults are enabled
            Write-Host "Starting full installation..." -ForegroundColor Green
        }
        '2' {
            # Dry-Run Mode
            $DryRun = $true
            $env:DRYRUN_MODE = "true"
        }
        '3' {
            # Custom Installation
            $customOptions = Show-CustomMenu
            if ($null -eq $customOptions) {
                # User chose to go back, show menu again
                $menuChoice = Show-Menu
                # Process the new choice recursively
                if ($menuChoice -eq 'Q' -or $menuChoice -eq 'q') {
                    Write-ColorOutput "Setup cancelled by user." "Yellow"
                    exit 0
                }
            }
            else {
                # Apply custom options
                $SkipSoftware = -not $customOptions.Software
                $SkipSystemConfig = -not $customOptions.SystemConfig
                $SkipEnvironment = -not $customOptions.Environment
                $SkipDrivers = -not $customOptions.Drivers
                $SkipWSL = -not $customOptions.WSL
                $SkipTelemetry = -not $customOptions.Telemetry
                $SkipPowerShell = -not $customOptions.PowerShell
                $SkipGitConfig = -not $customOptions.GitConfig
                if ($customOptions.DryRun) {
                    $DryRun = $true
                    $env:DRYRUN_MODE = "true"
                }
            }
        }
        '4' {
            # Quick Install
            $SkipDrivers = $true
            $SkipWSL = $true
        }
        { $_ -eq 'Q' -or $_ -eq 'q' } {
            Write-ColorOutput "Setup cancelled by user." "Yellow"
            exit 0
        }
        default {
            Write-ColorOutput "Invalid choice. Starting full installation..." "Yellow"
            Start-Sleep -Seconds 2
        }
    }
}

# ========================================
# Pre-flight Checks
# ========================================
Clear-Host

Write-ColorOutput "" "Cyan"
Write-ColorOutput "    ╔═══════════════════════════════════════════════════════════╗" "Cyan"
Write-ColorOutput "    ║                                                           ║" "Cyan"
Write-ColorOutput "    ║          Windows 11 Automated Setup Script               ║" "Cyan"
Write-ColorOutput "    ║          Opinionated & Optimized                         ║" "Cyan"
Write-ColorOutput "    ║                                                           ║" "Cyan"
Write-ColorOutput "    ╚═══════════════════════════════════════════════════════════╝" "Cyan"
Write-ColorOutput "" "Cyan"

Write-ColorOutput "Starting setup at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "White"
Write-ColorOutput "Log file: $LogFile" "Gray"

# Check administrator privileges (skip in dry-run mode)
if (-not $DryRun) {
    if (-not (Test-Administrator)) {
        Write-ColorOutput "`nWarning: This script is not running with Administrator privileges!" "Yellow"
        Write-ColorOutput "Some operations may fail without admin rights." "Yellow"
        Write-ColorOutput "`nWould you like to restart with Administrator privileges? (Y/N)" "Cyan"
        $response = Read-Host

        if ($response -eq 'Y' -or $response -eq 'y') {
            # Build parameters string
            $paramString = @()
            if ($SkipSoftware) { $paramString += "-SkipSoftware" }
            if ($SkipSystemConfig) { $paramString += "-SkipSystemConfig" }
            if ($SkipEnvironment) { $paramString += "-SkipEnvironment" }
            if ($SkipDrivers) { $paramString += "-SkipDrivers" }
            if ($SkipWSL) { $paramString += "-SkipWSL" }
            if ($SkipTelemetry) { $paramString += "-SkipTelemetry" }
            if ($SkipPowerShell) { $paramString += "-SkipPowerShell" }
            if ($NoMenu) { $paramString += "-NoMenu" }

            $scriptPath = $PSCommandPath
            $params = $paramString -join " "

            # Restart with admin privileges
            Start-Process powershell -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$scriptPath`" $params"
            exit 0
        }
        else {
            Write-ColorOutput "Continuing without Administrator privileges..." "Yellow"
            Write-ColorOutput "Note: Some operations may fail." "Gray"
        }
    }
    else {
        Write-ColorOutput "✓ Running with Administrator privileges" "Green"
    }
}
else {
    Write-ColorOutput "⚠ DRY-RUN MODE - No changes will be made" "Yellow"
    if (Test-Administrator) {
        Write-ColorOutput "✓ Running with Administrator privileges (not required in dry-run)" "Gray"
    }
    else {
        Write-ColorOutput "ℹ Not running as Administrator (OK for dry-run mode)" "Gray"
    }
}

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-ColorOutput "PowerShell Version: $($psVersion.Major).$($psVersion.Minor).$($psVersion.Build)" "Gray"

if ($psVersion.Major -lt 5) {
    Write-ColorOutput "`nWarning: PowerShell 5.0 or higher is recommended" "Yellow"
}

# Display what will be executed
Write-ColorOutput "`nSetup Configuration:" "White"
if ($DryRun) {
    Write-ColorOutput "  Mode: DRY-RUN (Preview Only)" "Cyan"
}
Write-ColorOutput "  Software Installation: $(if ($SkipSoftware) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipSoftware) { "Yellow" } else { "Green" })
Write-ColorOutput "  System Configuration: $(if ($SkipSystemConfig) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipSystemConfig) { "Yellow" } else { "Green" })
Write-ColorOutput "  Environment Variables: $(if ($SkipEnvironment) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipEnvironment) { "Yellow" } else { "Green" })
Write-ColorOutput "  Driver Installation: $(if ($SkipDrivers) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipDrivers) { "Yellow" } else { "Green" })
Write-ColorOutput "  WSL Installation: $(if ($SkipWSL) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipWSL) { "Yellow" } else { "Green" })
Write-ColorOutput "  Disable Telemetry: $(if ($SkipTelemetry) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipTelemetry) { "Yellow" } else { "Green" })
Write-ColorOutput "  PowerShell Config: $(if ($SkipPowerShell) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipPowerShell) { "Yellow" } else { "Green" })
Write-ColorOutput "  Git and GitHub Config: $(if ($SkipGitConfig) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipGitConfig) { "Yellow" } else { "Green" })

Write-ColorOutput "`nPress Ctrl+C to cancel, or" "Yellow"
Read-Host "Press Enter to continue"

# ========================================
# Main Execution
# ========================================
$overallStartTime = Get-Date
$executedModules = 0
$successfulModules = 0
$failedModules = @()

# Module 1: Software Installation
if (-not $SkipSoftware) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\install-software.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Software Installation" -Description "STEP 1: Installing Software Packages") {
        $successfulModules++
    }
    else {
        $failedModules += "Software Installation"
    }
}

# Module 2: System Configuration
if (-not $SkipSystemConfig) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\configure-system.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "System Configuration" -Description "STEP 2: Configuring Windows Settings") {
        $successfulModules++
    }
    else {
        $failedModules += "System Configuration"
    }
}

# Module 3: Disable Telemetry and Privacy Tracking
if (-not $SkipTelemetry) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\disable-telemetry.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Privacy & Telemetry" -Description "STEP 3: Disabling Telemetry & Privacy Tracking") {
        $successfulModules++
    }
    else {
        $failedModules += "Privacy & Telemetry"
    }
}

# Module 4: Environment Variables
if (-not $SkipEnvironment) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\setup-env.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Environment Setup" -Description "STEP 4: Setting Up Environment Variables") {
        $successfulModules++
    }
    else {
        $failedModules += "Environment Setup"
    }
}

# Module 5: PowerShell Profile Configuration
if (-not $SkipPowerShell) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\configure-powershell.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "PowerShell Profile" -Description "STEP 5: Configuring PowerShell Profile & Starship") {
        $successfulModules++
    }
    else {
        $failedModules += "PowerShell Profile"
    }
}

# Module 6: Scoop Package Manager
$executedModules++
$modulePath = Join-Path $ScriptRoot "scripts\install-scoop.ps1"
if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Scoop & Dev Tools" -Description "STEP 6: Installing Scoop, GCC & tree-sitter") {
    $successfulModules++
}
else {
    $failedModules += "Scoop & Dev Tools"
}

# Module 7: Nerd Fonts
$executedModules++
$modulePath = Join-Path $ScriptRoot "scripts\install-fonts.ps1"
if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Nerd Fonts" -Description "STEP 7: Installing CaskaydiaCove Nerd Font") {
    $successfulModules++
}
else {
    $failedModules += "Nerd Fonts"
}

# Module 8: Hardware Detection & Driver Installation
if (-not $SkipDrivers) {
    # Step 8a: Detect Hardware
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\detect-hardware.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Hardware Detection" -Description "STEP 8a: Detecting System Hardware") {
        $successfulModules++
    }
    else {
        $failedModules += "Hardware Detection"
    }

    # Step 8b: Install Drivers
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\install-drivers.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Driver Installation" -Description "STEP 8b: Installing Hardware Drivers") {
        $successfulModules++
    }
    else {
        $failedModules += "Driver Installation"
    }
}

# Module 9: WSL Installation
if (-not $SkipWSL) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\enable-wsl.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "WSL Installation" -Description "STEP 9: Installing Windows Subsystem for Linux") {
        $successfulModules++
    }
    else {
        $failedModules += "WSL Installation"
    }
}

# Module 10: Git and GitHub Configuration
if (-not $SkipGitConfig) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\configure-git.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Git and GitHub Config" -Description "STEP 10: Configuring Git and GitHub") {
        $successfulModules++
    }
    else {
        $failedModules += "Git and GitHub Config"
    }
}

# ========================================
# Final Summary
# ========================================
$overallDuration = (Get-Date) - $overallStartTime

Write-Header "SETUP COMPLETE"

Write-ColorOutput "`nExecution Summary:" "White"
Write-ColorOutput "  Total modules executed: $executedModules" "White"
Write-ColorOutput "  Successful: $successfulModules" "Green"
Write-ColorOutput "  Failed: $($failedModules.Count)" $(if ($failedModules.Count -gt 0) { "Red" } else { "Green" })
Write-ColorOutput "  Total duration: $([math]::Round($overallDuration.TotalMinutes, 2)) minutes" "White"

if ($failedModules.Count -gt 0) {
    Write-ColorOutput "`nFailed modules:" "Red"
    foreach ($module in $failedModules) {
        Write-ColorOutput "  - $module" "Red"
    }
}

Write-ColorOutput "`nLog file saved to: $LogFile" "Gray"

# ========================================
# Post-Setup Recommendations
# ========================================
Write-ColorOutput "`n" "White"
Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" "Cyan"
Write-ColorOutput "║              RECOMMENDED NEXT STEPS                       ║" "Cyan"
Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "  1. Restart your computer to apply all changes" "Yellow"
Write-ColorOutput "  2. After restart, launch Ubuntu from Start Menu to complete WSL setup" "Yellow"
Write-ColorOutput "  3. Configure Starship prompt (if not done):" "Yellow"
Write-ColorOutput "     Add to PowerShell profile: Invoke-Expression (&starship init powershell)" "Gray"
Write-ColorOutput "  4. Sign into your applications:" "Yellow"
Write-ColorOutput "     - 1Password" "Gray"
Write-ColorOutput "     - Google Chrome" "Gray"
Write-ColorOutput "     - Discord, Slack, Zoom" "Gray"
Write-ColorOutput "  5. Configure Git:" "Yellow"
Write-ColorOutput "     git config --global user.name 'Your Name'" "Gray"
Write-ColorOutput "     git config --global user.email 'your.email@example.com'" "Gray"
Write-ColorOutput ""

if ($successfulModules -eq $executedModules) {
    Write-ColorOutput "All modules completed successfully! Enjoy your optimized Windows 11 setup!" "Green"
}
else {
    Write-ColorOutput "Setup completed with some errors. Please review the log file." "Yellow"
}

Write-ColorOutput "`nPress Enter to exit..." "White"
Read-Host
