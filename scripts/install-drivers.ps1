# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Installs hardware drivers based on detected system configuration.

.DESCRIPTION
    Uses hardware detection data to automatically install appropriate drivers for:
    - Graphics cards (NVIDIA, AMD, Intel)
    - Audio devices
    - Network adapters (Intel, Realtek)
    - Chipset drivers

    Drivers are installed via winget where available, with fallback to Windows Update.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.PARAMETER HardwareInfoPath
    Path to the hardware-info.json file created by detect-hardware.ps1

.EXAMPLE
    .\install-drivers.ps1 -HardwareInfoPath "..\hardware-info.json"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$HardwareInfoPath = "$PSScriptRoot\..\hardware-info.json"
)

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Install-DriverPackage {
    param(
        [string]$PackageId,
        [string]$PackageName,
        [string]$DeviceType
    )

    Write-ColorOutput "`nInstalling $PackageName driver for $DeviceType..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install driver: $PackageName ($PackageId) for $DeviceType"
        return $true
    }

    try {
        # Check if already installed
        $installed = winget list --id $PackageId --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
            Write-ColorOutput "  + $PackageName driver is already installed" "Gray"
            return $true
        }

        # Install the driver
        winget install --id $PackageId --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $PackageName driver installed successfully" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $PackageName driver (exit code: $LASTEXITCODE)" "Yellow"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing $PackageName driver: $_" "Red"
        return $false
    }
}

function Install-GPUDrivers {
    param($GPUList)

    Write-ColorOutput "`n[Installing GPU Drivers]" "Cyan"

    if ($GPUList.Count -eq 0) {
        Write-ColorOutput "  No discrete GPUs detected, skipping..." "Gray"
        return
    }

    $installedCount = 0

    foreach ($gpu in $GPUList) {
        switch ($gpu.Vendor) {
            "NVIDIA" {
                Write-ColorOutput "`n  Detected NVIDIA GPU: $($gpu.Name)" "White"
                if (Install-DriverPackage -PackageId "Nvidia.GeForceExperience" -PackageName "NVIDIA GeForce Experience" -DeviceType "NVIDIA GPU") {
                    $installedCount++
                }
            }
            "AMD" {
                Write-ColorOutput "`n  Detected AMD GPU: $($gpu.Name)" "White"
                if (Install-DriverPackage -PackageId "AMD.AMDSoftwareAdrenalinEdition" -PackageName "AMD Adrenalin" -DeviceType "AMD GPU") {
                    $installedCount++
                }
            }
            "Intel" {
                Write-ColorOutput "`n  Detected Intel GPU: $($gpu.Name)" "White"
                Write-ColorOutput "  â„ą Intel graphics drivers are usually installed via Windows Update" "Gray"
                Write-ColorOutput "  You can manually download from: https://www.intel.com/content/www/us/en/download-center/home.html" "Gray"
            }
            default {
                Write-ColorOutput "`n  Unknown GPU vendor: $($gpu.Name)" "Yellow"
            }
        }
    }

    Write-ColorOutput "`n  GPU drivers installation: $installedCount/$($GPUList.Count) completed" "White"
}

function Install-AudioDrivers {
    param($AudioList)

    Write-ColorOutput "`n[Installing Audio Drivers]" "Cyan"

    if ($AudioList.Count -eq 0) {
        Write-ColorOutput "  No audio devices detected, skipping..." "Gray"
        return
    }

    $installedCount = 0
    $processedVendors = @()

    foreach ($device in $AudioList) {
        # Skip if we already processed this vendor
        if ($processedVendors -contains $device.Vendor) {
            continue
        }

        $processedVendors += $device.Vendor

        switch ($device.Vendor) {
            "Focusrite" {
                Write-ColorOutput "`n  Detected Focusrite Audio: $($device.Name)" "White"
                # Focusrite drivers need to be downloaded manually
                Write-ColorOutput "  â„ą Focusrite drivers should be downloaded from:" "Gray"
                Write-ColorOutput "    https://focusrite.com/downloads" "Cyan"
            }
            "Realtek" {
                Write-ColorOutput "`n  Detected Realtek Audio: $($device.Name)" "White"
                Write-ColorOutput "  â„ą Realtek audio drivers are usually included with Windows Update" "Gray"
            }
            default {
                Write-ColorOutput "`n  Detected: $($device.Name) [$($device.Vendor)]" "White"
                Write-ColorOutput "  â„ą Audio drivers are typically installed automatically via Windows Update" "Gray"
            }
        }
    }
}

function Install-NetworkDrivers {
    param($NetworkList)

    Write-ColorOutput "`n[Installing Network Drivers]" "Cyan"

    if ($NetworkList.Count -eq 0) {
        Write-ColorOutput "  No network adapters detected, skipping..." "Gray"
        return
    }

    $processedVendors = @()

    foreach ($adapter in $NetworkList) {
        # Skip if we already processed this vendor/type combo
        $vendorKey = "$($adapter.Vendor)-$($adapter.Type)"
        if ($processedVendors -contains $vendorKey) {
            continue
        }

        $processedVendors += $vendorKey

        Write-ColorOutput "`n  Detected: $($adapter.Name) [$($adapter.Type)]" "White"

        if ($adapter.Vendor -eq "Intel" -and $adapter.Type -eq "WiFi") {
            Write-ColorOutput "  â„ą Intel WiFi drivers are available via Windows Update" "Gray"
            Write-ColorOutput "    For latest drivers: https://www.intel.com/content/www/us/en/download-center/home.html" "Gray"
        }
        elseif ($adapter.Vendor -eq "Intel" -and $adapter.Type -eq "Ethernet") {
            Write-ColorOutput "  â„ą Intel Ethernet drivers are available via Windows Update" "Gray"
        }
        elseif ($adapter.Vendor -eq "Realtek") {
            Write-ColorOutput "  â„ą Realtek drivers are usually included with Windows Update" "Gray"
        }
        else {
            Write-ColorOutput "  â„ą Network drivers are typically installed automatically via Windows Update" "Gray"
        }
    }
}

function Install-ChipsetDrivers {
    param($CPUInfo, $SystemInfo)

    Write-ColorOutput "`n[Installing Chipset Drivers]" "Cyan"

    if ($null -eq $CPUInfo) {
        Write-ColorOutput "  No CPU info available, skipping..." "Gray"
        return
    }

    Write-ColorOutput "`n  Detected CPU: $($CPUInfo.Name) [$($CPUInfo.Vendor)]" "White"

    switch ($CPUInfo.Vendor) {
        "Intel" {
            Write-ColorOutput "  â„ą Intel chipset drivers available at:" "Gray"
            Write-ColorOutput "    https://www.intel.com/content/www/us/en/download-center/home.html" "Cyan"
            Write-ColorOutput "  Or install Intel Driver and Support Assistant via winget:" "Gray"
            Install-DriverPackage -PackageId "Intel.IntelDriverAndSupportAssistant" -PackageName "Intel DSA" -DeviceType "Intel System"
        }
        "AMD" {
            Write-ColorOutput "  â„ą AMD chipset drivers available at:" "Gray"
            Write-ColorOutput "    https://www.amd.com/en/support" "Cyan"
        }
        default {
            Write-ColorOutput "  Unknown CPU vendor: $($CPUInfo.Vendor)" "Yellow"
        }
    }

    # Lenovo-specific drivers
    if ($SystemInfo.Manufacturer -match "Lenovo") {
        Write-ColorOutput "`n  Detected Lenovo system" "White"
        Write-ColorOutput "  Installing Lenovo System Update..." "Cyan"
        if (Install-DriverPackage -PackageId "Lenovo.SystemUpdate" -PackageName "Lenovo System Update" -DeviceType "Lenovo System") {
            Write-ColorOutput "  â„ą Use Lenovo System Update to install manufacturer-specific drivers" "Gray"
        }
    }
    # Dell-specific drivers
    elseif ($SystemInfo.Manufacturer -match "Dell") {
        Write-ColorOutput "`n  Detected Dell system" "White"
        Write-ColorOutput "  Installing Dell Command Update..." "Cyan"
        Install-DriverPackage -PackageId "Dell.CommandUpdate" -PackageName "Dell Command Update" -DeviceType "Dell System"
    }
    # HP-specific drivers
    elseif ($SystemInfo.Manufacturer -match "HP|Hewlett") {
        Write-ColorOutput "`n  Detected HP system" "White"
        Write-ColorOutput "  â„ą HP Support Assistant may be pre-installed" "Gray"
        Write-ColorOutput "  Download from: https://support.hp.com/us-en/help/hp-support-assistant" "Cyan"
    }
}

function Invoke-WindowsUpdate {
    Write-ColorOutput "`n[Triggering Windows Update for Drivers]" "Cyan"

    Write-ColorOutput "  â„ą Running Windows Update to install missing drivers..." "Gray"

    try {
        # Install PSWindowsUpdate module if not present
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-ColorOutput "  Installing PSWindowsUpdate module..." "Yellow"
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction SilentlyContinue
        }

        if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
            Import-Module PSWindowsUpdate
            Write-ColorOutput "  Starting Windows Update scan for drivers..." "Cyan"
            Get-WindowsUpdate -MicrosoftUpdate -Install -UpdateType Driver -AcceptAll -AutoReboot:$false -Verbose
            Write-ColorOutput "  + Windows Update driver scan complete" "Green"
        }
        else {
            Write-ColorOutput "  âš  PSWindowsUpdate module not available" "Yellow"
            Write-ColorOutput "  Please run Windows Update manually from Settings > Windows Update" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "  âš  Could not run Windows Update automatically: $_" "Yellow"
        Write-ColorOutput "  Please run Windows Update manually from Settings > Windows Update" "Yellow"
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Driver Installation" "Magenta"
Write-ColorOutput "========================================" "Magenta"

# Check if hardware info exists
if (-not (Test-Path $HardwareInfoPath)) {
    Write-ColorOutput "`nHardware information file not found: $HardwareInfoPath" "Red"
    Write-ColorOutput "Please run detect-hardware.ps1 first!" "Yellow"
    exit 1
}

# Load hardware information
try {
    $hardwareInfo = Get-Content $HardwareInfoPath -Raw | ConvertFrom-Json
    Write-ColorOutput "+ Hardware information loaded successfully" "Green"
}
catch {
    Write-ColorOutput "Failed to load hardware information: $_" "Red"
    exit 1
}

# Install drivers based on detected hardware
Install-GPUDrivers -GPUList $hardwareInfo.GPU
Install-AudioDrivers -AudioList $hardwareInfo.Audio
Install-NetworkDrivers -NetworkList $hardwareInfo.Network
Install-ChipsetDrivers -CPUInfo $hardwareInfo.CPU -SystemInfo $hardwareInfo.System

# Trigger Windows Update for remaining drivers
Invoke-WindowsUpdate

# Summary
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Driver Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "`nDriver installation process complete!" "Green"
Write-ColorOutput "`nâ„ą Important Notes:" "Yellow"
Write-ColorOutput "  1. Some drivers may require a system restart to take effect" "White"
Write-ColorOutput "  2. Run Windows Update manually to ensure all drivers are current" "White"
Write-ColorOutput "  3. For manufacturer-specific drivers (Lenovo, Dell, HP), use their update tools" "White"
Write-ColorOutput "  4. Graphics drivers may need manual installation for optimal performance" "White"

Write-ColorOutput "`nRecommended Actions:" "Cyan"
Write-ColorOutput "  - Restart your computer" "Gray"
Write-ColorOutput "  - Check Windows Update (Settings > Windows Update)" "Gray"
Write-ColorOutput "  - Run manufacturer update tool if applicable (Lenovo/Dell/HP)" "Gray"
Write-ColorOutput "  - Verify Device Manager for any missing drivers" "Gray"
