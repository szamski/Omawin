# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Enables Windows Subsystem for Linux (WSL) and installs default distribution.

.DESCRIPTION
    Enables WSL 2, Virtual Machine Platform, and installs Ubuntu as the default Linux distribution.
    Checks if WSL is already enabled before making changes.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\enable-wsl.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WSLEnabled {
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        return ($wslFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Test-VirtualMachinePlatformEnabled {
    try {
        $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction Stop
        return ($vmFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Enable-WSLFeature {
    Write-ColorOutput "`nEnabling Windows Subsystem for Linux..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: Microsoft-Windows-Subsystem-Linux"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + WSL feature enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + WSL feature enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable WSL: $(# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Enables Windows Subsystem for Linux (WSL) and installs default distribution.

.DESCRIPTION
    Enables WSL 2, Virtual Machine Platform, and installs Ubuntu as the default Linux distribution.
    Checks if WSL is already enabled before making changes.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\enable-wsl.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WSLEnabled {
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        return ($wslFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Test-VirtualMachinePlatformEnabled {
    try {
        $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction Stop
        return ($vmFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Enable-WSLFeature {
    Write-ColorOutput "`nEnabling Windows Subsystem for Linux..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: Microsoft-Windows-Subsystem-Linux"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + WSL feature enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + WSL feature enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable WSL: $_" "Red"
        return $false
    }
}

function Enable-VirtualMachinePlatformFeature {
    Write-ColorOutput "`nEnabling Virtual Machine Platform..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: VirtualMachinePlatform"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + Virtual Machine Platform enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + Virtual Machine Platform enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable Virtual Machine Platform: $_" "Red"
        return $false
    }
}

function Set-WSL2AsDefault {
    Write-ColorOutput "`nSetting WSL 2 as default version..." "Cyan"

    try {
        wsl --set-default-version 2 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + WSL 2 set as default version" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to set WSL 2 as default (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error setting WSL 2 as default: $_" "Red"
        return $false
    }
}

function Install-WSLDistribution {
    param(
        [string]$Distribution = "Ubuntu"
    )

    Write-ColorOutput "`nInstalling $Distribution distribution..." "Cyan"

    try {
        # Check if distribution is already installed
        $installed = wsl --list 2>&1
        if ($installed -match $Distribution) {
            Write-ColorOutput "  o $Distribution is already installed" "Gray"
            return $true
        }

        # Install the distribution
        wsl --install -d $Distribution

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $Distribution installed successfully" "Green"
            Write-ColorOutput "  Note: You'll need to complete the initial setup when you first launch Ubuntu" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $Distribution (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing $Distribution : $_" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  WSL Installation & Configuration" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$restartRequired = $false
$successCount = 0
$totalSteps = 0

# ========================================
# Check and Enable WSL
# ========================================
Write-ColorOutput "`n[Step 1: Windows Subsystem for Linux]" "Cyan"
$totalSteps++

if (Test-WSLEnabled) {
    Write-ColorOutput "  o WSL is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-WSLFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Check and Enable Virtual Machine Platform
# ========================================
Write-ColorOutput "`n[Step 2: Virtual Machine Platform]" "Cyan"
$totalSteps++

if (Test-VirtualMachinePlatformEnabled) {
    Write-ColorOutput "  o Virtual Machine Platform is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-VirtualMachinePlatformFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Set WSL 2 as Default
# ========================================
Write-ColorOutput "`n[Step 3: WSL 2 Default Version]" "Cyan"
$totalSteps++

if (Set-WSL2AsDefault) {
    $successCount++
}

# ========================================
# Install Ubuntu Distribution
# ========================================
Write-ColorOutput "`n[Step 4: Install Linux Distribution]" "Cyan"
$totalSteps++

if (-not $restartRequired) {
    if (Install-WSLDistribution -Distribution "Ubuntu") {
        $successCount++
    }
}
else {
    Write-ColorOutput "  âš  Skipping distribution installation - restart required first" "Yellow"
    Write-ColorOutput "  After restarting, run: wsl --install -d Ubuntu" "Yellow"
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  WSL Setup Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($restartRequired) {
    Write-ColorOutput "`nâš  RESTART REQUIRED!" "Red"
    Write-ColorOutput "Windows features have been enabled that require a system restart." "Yellow"
    Write-ColorOutput "After restarting, run this script again to complete WSL installation." "Yellow"
    Write-ColorOutput "`nAlternatively, after restart, you can manually run:" "Yellow"
    Write-ColorOutput "  wsl --set-default-version 2" "Cyan"
    Write-ColorOutput "  wsl --install -d Ubuntu" "Cyan"
}
elseif ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nWSL setup completed successfully!" "Green"
    Write-ColorOutput "`nTo start using WSL:" "White"
    Write-ColorOutput "  1. Open 'Ubuntu' from Start Menu" "Cyan"
    Write-ColorOutput "  2. Complete the initial setup (username and password)" "Cyan"
    Write-ColorOutput "  3. Start developing with Linux tools!" "Cyan"
}
else {
    Write-ColorOutput "`nWSL setup completed with some errors. Please check the output above." "Yellow"
}

# ========================================
# Additional Information
# ========================================
Write-ColorOutput "`n[Useful WSL Commands]" "Cyan"
Write-ColorOutput "  wsl --list --verbose         # List installed distributions" "Gray"
Write-ColorOutput "  wsl --set-default <distro>   # Set default distribution" "Gray"
Write-ColorOutput "  wsl --shutdown               # Shutdown all WSL instances" "Gray"
Write-ColorOutput "  wsl --update                 # Update WSL kernel" "Gray"
.Exception.Message)" "Red"
        return $false
    }
}

function Enable-VirtualMachinePlatformFeature {
    Write-ColorOutput "`nEnabling Virtual Machine Platform..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: VirtualMachinePlatform"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + Virtual Machine Platform enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + Virtual Machine Platform enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable Virtual Machine Platform: $(# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Enables Windows Subsystem for Linux (WSL) and installs default distribution.

.DESCRIPTION
    Enables WSL 2, Virtual Machine Platform, and installs Ubuntu as the default Linux distribution.
    Checks if WSL is already enabled before making changes.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\enable-wsl.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WSLEnabled {
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        return ($wslFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Test-VirtualMachinePlatformEnabled {
    try {
        $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction Stop
        return ($vmFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Enable-WSLFeature {
    Write-ColorOutput "`nEnabling Windows Subsystem for Linux..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: Microsoft-Windows-Subsystem-Linux"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + WSL feature enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + WSL feature enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable WSL: $_" "Red"
        return $false
    }
}

function Enable-VirtualMachinePlatformFeature {
    Write-ColorOutput "`nEnabling Virtual Machine Platform..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: VirtualMachinePlatform"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + Virtual Machine Platform enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + Virtual Machine Platform enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable Virtual Machine Platform: $_" "Red"
        return $false
    }
}

function Set-WSL2AsDefault {
    Write-ColorOutput "`nSetting WSL 2 as default version..." "Cyan"

    try {
        wsl --set-default-version 2 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + WSL 2 set as default version" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to set WSL 2 as default (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error setting WSL 2 as default: $_" "Red"
        return $false
    }
}

function Install-WSLDistribution {
    param(
        [string]$Distribution = "Ubuntu"
    )

    Write-ColorOutput "`nInstalling $Distribution distribution..." "Cyan"

    try {
        # Check if distribution is already installed
        $installed = wsl --list 2>&1
        if ($installed -match $Distribution) {
            Write-ColorOutput "  o $Distribution is already installed" "Gray"
            return $true
        }

        # Install the distribution
        wsl --install -d $Distribution

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $Distribution installed successfully" "Green"
            Write-ColorOutput "  Note: You'll need to complete the initial setup when you first launch Ubuntu" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $Distribution (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing $Distribution : $_" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  WSL Installation & Configuration" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$restartRequired = $false
$successCount = 0
$totalSteps = 0

# ========================================
# Check and Enable WSL
# ========================================
Write-ColorOutput "`n[Step 1: Windows Subsystem for Linux]" "Cyan"
$totalSteps++

if (Test-WSLEnabled) {
    Write-ColorOutput "  o WSL is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-WSLFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Check and Enable Virtual Machine Platform
# ========================================
Write-ColorOutput "`n[Step 2: Virtual Machine Platform]" "Cyan"
$totalSteps++

if (Test-VirtualMachinePlatformEnabled) {
    Write-ColorOutput "  o Virtual Machine Platform is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-VirtualMachinePlatformFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Set WSL 2 as Default
# ========================================
Write-ColorOutput "`n[Step 3: WSL 2 Default Version]" "Cyan"
$totalSteps++

if (Set-WSL2AsDefault) {
    $successCount++
}

# ========================================
# Install Ubuntu Distribution
# ========================================
Write-ColorOutput "`n[Step 4: Install Linux Distribution]" "Cyan"
$totalSteps++

if (-not $restartRequired) {
    if (Install-WSLDistribution -Distribution "Ubuntu") {
        $successCount++
    }
}
else {
    Write-ColorOutput "  âš  Skipping distribution installation - restart required first" "Yellow"
    Write-ColorOutput "  After restarting, run: wsl --install -d Ubuntu" "Yellow"
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  WSL Setup Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($restartRequired) {
    Write-ColorOutput "`nâš  RESTART REQUIRED!" "Red"
    Write-ColorOutput "Windows features have been enabled that require a system restart." "Yellow"
    Write-ColorOutput "After restarting, run this script again to complete WSL installation." "Yellow"
    Write-ColorOutput "`nAlternatively, after restart, you can manually run:" "Yellow"
    Write-ColorOutput "  wsl --set-default-version 2" "Cyan"
    Write-ColorOutput "  wsl --install -d Ubuntu" "Cyan"
}
elseif ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nWSL setup completed successfully!" "Green"
    Write-ColorOutput "`nTo start using WSL:" "White"
    Write-ColorOutput "  1. Open 'Ubuntu' from Start Menu" "Cyan"
    Write-ColorOutput "  2. Complete the initial setup (username and password)" "Cyan"
    Write-ColorOutput "  3. Start developing with Linux tools!" "Cyan"
}
else {
    Write-ColorOutput "`nWSL setup completed with some errors. Please check the output above." "Yellow"
}

# ========================================
# Additional Information
# ========================================
Write-ColorOutput "`n[Useful WSL Commands]" "Cyan"
Write-ColorOutput "  wsl --list --verbose         # List installed distributions" "Gray"
Write-ColorOutput "  wsl --set-default <distro>   # Set default distribution" "Gray"
Write-ColorOutput "  wsl --shutdown               # Shutdown all WSL instances" "Gray"
Write-ColorOutput "  wsl --update                 # Update WSL kernel" "Gray"
.Exception.Message)" "Red"
        return $false
    }
}

function Set-WSL2AsDefault {
    Write-ColorOutput "`nSetting WSL 2 as default version..." "Cyan"

    try {
        wsl --set-default-version 2 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + WSL 2 set as default version" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to set WSL 2 as default (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error setting WSL 2 as default: $(# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Enables Windows Subsystem for Linux (WSL) and installs default distribution.

.DESCRIPTION
    Enables WSL 2, Virtual Machine Platform, and installs Ubuntu as the default Linux distribution.
    Checks if WSL is already enabled before making changes.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\enable-wsl.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WSLEnabled {
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        return ($wslFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Test-VirtualMachinePlatformEnabled {
    try {
        $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction Stop
        return ($vmFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Enable-WSLFeature {
    Write-ColorOutput "`nEnabling Windows Subsystem for Linux..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: Microsoft-Windows-Subsystem-Linux"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + WSL feature enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + WSL feature enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable WSL: $_" "Red"
        return $false
    }
}

function Enable-VirtualMachinePlatformFeature {
    Write-ColorOutput "`nEnabling Virtual Machine Platform..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: VirtualMachinePlatform"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + Virtual Machine Platform enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + Virtual Machine Platform enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable Virtual Machine Platform: $_" "Red"
        return $false
    }
}

function Set-WSL2AsDefault {
    Write-ColorOutput "`nSetting WSL 2 as default version..." "Cyan"

    try {
        wsl --set-default-version 2 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + WSL 2 set as default version" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to set WSL 2 as default (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error setting WSL 2 as default: $_" "Red"
        return $false
    }
}

function Install-WSLDistribution {
    param(
        [string]$Distribution = "Ubuntu"
    )

    Write-ColorOutput "`nInstalling $Distribution distribution..." "Cyan"

    try {
        # Check if distribution is already installed
        $installed = wsl --list 2>&1
        if ($installed -match $Distribution) {
            Write-ColorOutput "  o $Distribution is already installed" "Gray"
            return $true
        }

        # Install the distribution
        wsl --install -d $Distribution

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $Distribution installed successfully" "Green"
            Write-ColorOutput "  Note: You'll need to complete the initial setup when you first launch Ubuntu" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $Distribution (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing $Distribution : $_" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  WSL Installation & Configuration" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$restartRequired = $false
$successCount = 0
$totalSteps = 0

# ========================================
# Check and Enable WSL
# ========================================
Write-ColorOutput "`n[Step 1: Windows Subsystem for Linux]" "Cyan"
$totalSteps++

if (Test-WSLEnabled) {
    Write-ColorOutput "  o WSL is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-WSLFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Check and Enable Virtual Machine Platform
# ========================================
Write-ColorOutput "`n[Step 2: Virtual Machine Platform]" "Cyan"
$totalSteps++

if (Test-VirtualMachinePlatformEnabled) {
    Write-ColorOutput "  o Virtual Machine Platform is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-VirtualMachinePlatformFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Set WSL 2 as Default
# ========================================
Write-ColorOutput "`n[Step 3: WSL 2 Default Version]" "Cyan"
$totalSteps++

if (Set-WSL2AsDefault) {
    $successCount++
}

# ========================================
# Install Ubuntu Distribution
# ========================================
Write-ColorOutput "`n[Step 4: Install Linux Distribution]" "Cyan"
$totalSteps++

if (-not $restartRequired) {
    if (Install-WSLDistribution -Distribution "Ubuntu") {
        $successCount++
    }
}
else {
    Write-ColorOutput "  âš  Skipping distribution installation - restart required first" "Yellow"
    Write-ColorOutput "  After restarting, run: wsl --install -d Ubuntu" "Yellow"
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  WSL Setup Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($restartRequired) {
    Write-ColorOutput "`nâš  RESTART REQUIRED!" "Red"
    Write-ColorOutput "Windows features have been enabled that require a system restart." "Yellow"
    Write-ColorOutput "After restarting, run this script again to complete WSL installation." "Yellow"
    Write-ColorOutput "`nAlternatively, after restart, you can manually run:" "Yellow"
    Write-ColorOutput "  wsl --set-default-version 2" "Cyan"
    Write-ColorOutput "  wsl --install -d Ubuntu" "Cyan"
}
elseif ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nWSL setup completed successfully!" "Green"
    Write-ColorOutput "`nTo start using WSL:" "White"
    Write-ColorOutput "  1. Open 'Ubuntu' from Start Menu" "Cyan"
    Write-ColorOutput "  2. Complete the initial setup (username and password)" "Cyan"
    Write-ColorOutput "  3. Start developing with Linux tools!" "Cyan"
}
else {
    Write-ColorOutput "`nWSL setup completed with some errors. Please check the output above." "Yellow"
}

# ========================================
# Additional Information
# ========================================
Write-ColorOutput "`n[Useful WSL Commands]" "Cyan"
Write-ColorOutput "  wsl --list --verbose         # List installed distributions" "Gray"
Write-ColorOutput "  wsl --set-default <distro>   # Set default distribution" "Gray"
Write-ColorOutput "  wsl --shutdown               # Shutdown all WSL instances" "Gray"
Write-ColorOutput "  wsl --update                 # Update WSL kernel" "Gray"
.Exception.Message)" "Red"
        return $false
    }
}

function Install-WSLDistribution {
    param(
        [string]$Distribution = "Ubuntu"
    )

    Write-ColorOutput "`nInstalling $Distribution distribution..." "Cyan"

    try {
        # Check if distribution is already installed
        $installed = wsl --list 2>&1
        if ($installed -match $Distribution) {
            Write-ColorOutput "  o $Distribution is already installed" "Gray"
            return $true
        }

        # Install the distribution
        wsl --install -d $Distribution

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $Distribution installed successfully" "Green"
            Write-ColorOutput "  Note: You'll need to complete the initial setup when you first launch Ubuntu" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $Distribution (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing $Distribution : $(# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Enables Windows Subsystem for Linux (WSL) and installs default distribution.

.DESCRIPTION
    Enables WSL 2, Virtual Machine Platform, and installs Ubuntu as the default Linux distribution.
    Checks if WSL is already enabled before making changes.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\enable-wsl.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WSLEnabled {
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction Stop
        return ($wslFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Test-VirtualMachinePlatformEnabled {
    try {
        $vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction Stop
        return ($vmFeature.State -eq "Enabled")
    }
    catch {
        return $false
    }
}

function Enable-WSLFeature {
    Write-ColorOutput "`nEnabling Windows Subsystem for Linux..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: Microsoft-Windows-Subsystem-Linux"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + WSL feature enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + WSL feature enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable WSL: $_" "Red"
        return $false
    }
}

function Enable-VirtualMachinePlatformFeature {
    Write-ColorOutput "`nEnabling Virtual Machine Platform..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Enable Windows feature: VirtualMachinePlatform"
        return $true
    }

    try {
        $result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop

        if ($result.RestartNeeded) {
            Write-ColorOutput "  + Virtual Machine Platform enabled (restart required)" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  + Virtual Machine Platform enabled successfully" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to enable Virtual Machine Platform: $_" "Red"
        return $false
    }
}

function Set-WSL2AsDefault {
    Write-ColorOutput "`nSetting WSL 2 as default version..." "Cyan"

    try {
        wsl --set-default-version 2 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + WSL 2 set as default version" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to set WSL 2 as default (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error setting WSL 2 as default: $_" "Red"
        return $false
    }
}

function Install-WSLDistribution {
    param(
        [string]$Distribution = "Ubuntu"
    )

    Write-ColorOutput "`nInstalling $Distribution distribution..." "Cyan"

    try {
        # Check if distribution is already installed
        $installed = wsl --list 2>&1
        if ($installed -match $Distribution) {
            Write-ColorOutput "  o $Distribution is already installed" "Gray"
            return $true
        }

        # Install the distribution
        wsl --install -d $Distribution

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $Distribution installed successfully" "Green"
            Write-ColorOutput "  Note: You'll need to complete the initial setup when you first launch Ubuntu" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $Distribution (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing $Distribution : $_" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  WSL Installation & Configuration" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$restartRequired = $false
$successCount = 0
$totalSteps = 0

# ========================================
# Check and Enable WSL
# ========================================
Write-ColorOutput "`n[Step 1: Windows Subsystem for Linux]" "Cyan"
$totalSteps++

if (Test-WSLEnabled) {
    Write-ColorOutput "  o WSL is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-WSLFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Check and Enable Virtual Machine Platform
# ========================================
Write-ColorOutput "`n[Step 2: Virtual Machine Platform]" "Cyan"
$totalSteps++

if (Test-VirtualMachinePlatformEnabled) {
    Write-ColorOutput "  o Virtual Machine Platform is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-VirtualMachinePlatformFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Set WSL 2 as Default
# ========================================
Write-ColorOutput "`n[Step 3: WSL 2 Default Version]" "Cyan"
$totalSteps++

if (Set-WSL2AsDefault) {
    $successCount++
}

# ========================================
# Install Ubuntu Distribution
# ========================================
Write-ColorOutput "`n[Step 4: Install Linux Distribution]" "Cyan"
$totalSteps++

if (-not $restartRequired) {
    if (Install-WSLDistribution -Distribution "Ubuntu") {
        $successCount++
    }
}
else {
    Write-ColorOutput "  âš  Skipping distribution installation - restart required first" "Yellow"
    Write-ColorOutput "  After restarting, run: wsl --install -d Ubuntu" "Yellow"
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  WSL Setup Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($restartRequired) {
    Write-ColorOutput "`nâš  RESTART REQUIRED!" "Red"
    Write-ColorOutput "Windows features have been enabled that require a system restart." "Yellow"
    Write-ColorOutput "After restarting, run this script again to complete WSL installation." "Yellow"
    Write-ColorOutput "`nAlternatively, after restart, you can manually run:" "Yellow"
    Write-ColorOutput "  wsl --set-default-version 2" "Cyan"
    Write-ColorOutput "  wsl --install -d Ubuntu" "Cyan"
}
elseif ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nWSL setup completed successfully!" "Green"
    Write-ColorOutput "`nTo start using WSL:" "White"
    Write-ColorOutput "  1. Open 'Ubuntu' from Start Menu" "Cyan"
    Write-ColorOutput "  2. Complete the initial setup (username and password)" "Cyan"
    Write-ColorOutput "  3. Start developing with Linux tools!" "Cyan"
}
else {
    Write-ColorOutput "`nWSL setup completed with some errors. Please check the output above." "Yellow"
}

# ========================================
# Additional Information
# ========================================
Write-ColorOutput "`n[Useful WSL Commands]" "Cyan"
Write-ColorOutput "  wsl --list --verbose         # List installed distributions" "Gray"
Write-ColorOutput "  wsl --set-default <distro>   # Set default distribution" "Gray"
Write-ColorOutput "  wsl --shutdown               # Shutdown all WSL instances" "Gray"
Write-ColorOutput "  wsl --update                 # Update WSL kernel" "Gray"
.Exception.Message)" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  WSL Installation & Configuration" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$restartRequired = $false
$successCount = 0
$totalSteps = 0

# ========================================
# Check and Enable WSL
# ========================================
Write-ColorOutput "`n[Step 1: Windows Subsystem for Linux]" "Cyan"
$totalSteps++

if (Test-WSLEnabled) {
    Write-ColorOutput "  o WSL is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-WSLFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Check and Enable Virtual Machine Platform
# ========================================
Write-ColorOutput "`n[Step 2: Virtual Machine Platform]" "Cyan"
$totalSteps++

if (Test-VirtualMachinePlatformEnabled) {
    Write-ColorOutput "  o Virtual Machine Platform is already enabled" "Gray"
    $successCount++
}
else {
    if (Enable-VirtualMachinePlatformFeature) {
        $successCount++
        $restartRequired = $true
    }
}

# ========================================
# Set WSL 2 as Default
# ========================================
Write-ColorOutput "`n[Step 3: WSL 2 Default Version]" "Cyan"
$totalSteps++

if (Set-WSL2AsDefault) {
    $successCount++
}

# ========================================
# Install Ubuntu Distribution
# ========================================
Write-ColorOutput "`n[Step 4: Install Linux Distribution]" "Cyan"
$totalSteps++

if (-not $restartRequired) {
    if (Install-WSLDistribution -Distribution "Ubuntu") {
        $successCount++
    }
}
else {
    Write-ColorOutput "  âš  Skipping distribution installation - restart required first" "Yellow"
    Write-ColorOutput "  After restarting, run: wsl --install -d Ubuntu" "Yellow"
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  WSL Setup Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($restartRequired) {
    Write-ColorOutput "`nâš  RESTART REQUIRED!" "Red"
    Write-ColorOutput "Windows features have been enabled that require a system restart." "Yellow"
    Write-ColorOutput "After restarting, run this script again to complete WSL installation." "Yellow"
    Write-ColorOutput "`nAlternatively, after restart, you can manually run:" "Yellow"
    Write-ColorOutput "  wsl --set-default-version 2" "Cyan"
    Write-ColorOutput "  wsl --install -d Ubuntu" "Cyan"
}
elseif ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nWSL setup completed successfully!" "Green"
    Write-ColorOutput "`nTo start using WSL:" "White"
    Write-ColorOutput "  1. Open 'Ubuntu' from Start Menu" "Cyan"
    Write-ColorOutput "  2. Complete the initial setup (username and password)" "Cyan"
    Write-ColorOutput "  3. Start developing with Linux tools!" "Cyan"
}
else {
    Write-ColorOutput "`nWSL setup completed with some errors. Please check the output above." "Yellow"
}

# ========================================
# Additional Information
# ========================================
Write-ColorOutput "`n[Useful WSL Commands]" "Cyan"
Write-ColorOutput "  wsl --list --verbose         # List installed distributions" "Gray"
Write-ColorOutput "  wsl --set-default <distro>   # Set default distribution" "Gray"
Write-ColorOutput "  wsl --shutdown               # Shutdown all WSL instances" "Gray"
Write-ColorOutput "  wsl --update                 # Update WSL kernel" "Gray"

