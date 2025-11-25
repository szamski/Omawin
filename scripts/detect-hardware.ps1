# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Detects system hardware configuration.

.DESCRIPTION
    Scans the system to identify key hardware components including GPU, CPU, audio devices,
    network adapters, and other peripherals. Returns hardware information for driver installation.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\detect-hardware.ps1

.OUTPUTS
    Returns a hashtable containing detected hardware information
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Get-GPUInfo {
    Write-ColorOutput "`n[Detecting Graphics Cards]" "Cyan"

    try {
        $gpus = Get-CimInstance -ClassName Win32_VideoController | Where-Object { $_.Name -notmatch "Microsoft|Remote" }

        $gpuList = @()
        foreach ($gpu in $gpus) {
            $vendor = "Unknown"
            if ($gpu.Name -match "NVIDIA|GeForce|RTX|GTX") {
                $vendor = "NVIDIA"
            }
            elseif ($gpu.Name -match "AMD|Radeon|RX") {
                $vendor = "AMD"
            }
            elseif ($gpu.Name -match "Intel|UHD|Iris|Arc") {
                $vendor = "Intel"
            }

            $gpuInfo = @{
                Name = $gpu.Name
                Vendor = $vendor
                DriverVersion = $gpu.DriverVersion
                Status = $gpu.Status
            }

            $gpuList += $gpuInfo
            Write-ColorOutput "  + Found: $($gpu.Name) [$vendor]" "Green"
        }

        return $gpuList
    }
    catch {
        Write-ColorOutput "  X Error detecting GPU: $_" "Red"
        return @()
    }
}

function Get-CPUInfo {
    Write-ColorOutput "`n[Detecting Processor]" "Cyan"

    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

        $vendor = "Unknown"
        if ($cpu.Manufacturer -match "Intel") {
            $vendor = "Intel"
        }
        elseif ($cpu.Manufacturer -match "AMD") {
            $vendor = "AMD"
        }

        $cpuInfo = @{
            Name = $cpu.Name
            Vendor = $vendor
            Cores = $cpu.NumberOfCores
            LogicalProcessors = $cpu.NumberOfLogicalProcessors
        }

        Write-ColorOutput "  + Found: $($cpu.Name) [$vendor]" "Green"
        Write-ColorOutput "    Cores: $($cpu.NumberOfCores) | Threads: $($cpu.NumberOfLogicalProcessors)" "Gray"

        return $cpuInfo
    }
    catch {
        Write-ColorOutput "  X Error detecting CPU: $_" "Red"
        return $null
    }
}

function Get-AudioDevices {
    Write-ColorOutput "`n[Detecting Audio Devices]" "Cyan"

    try {
        $audioDevices = Get-CimInstance -ClassName Win32_SoundDevice | Where-Object { $_.Status -eq "OK" }

        $audioList = @()
        foreach ($device in $audioDevices) {
            $vendor = "Unknown"

            if ($device.Name -match "Realtek") {
                $vendor = "Realtek"
            }
            elseif ($device.Name -match "Focusrite") {
                $vendor = "Focusrite"
            }
            elseif ($device.Name -match "Intel") {
                $vendor = "Intel"
            }
            elseif ($device.Name -match "AMD") {
                $vendor = "AMD"
            }
            elseif ($device.Name -match "NVIDIA") {
                $vendor = "NVIDIA"
            }

            $audioInfo = @{
                Name = $device.Name
                Vendor = $vendor
                Status = $device.Status
            }

            $audioList += $audioInfo
            Write-ColorOutput "  + Found: $($device.Name) [$vendor]" "Green"
        }

        return $audioList
    }
    catch {
        Write-ColorOutput "  X Error detecting audio devices: $_" "Red"
        return @()
    }
}

function Get-NetworkAdapters {
    Write-ColorOutput "`n[Detecting Network Adapters]" "Cyan"

    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -or $_.MediaType -match "802.11|Ethernet" }

        $adapterList = @()
        foreach ($adapter in $adapters) {
            $vendor = "Unknown"
            $type = "Unknown"

            if ($adapter.InterfaceDescription -match "Intel") {
                $vendor = "Intel"
            }
            elseif ($adapter.InterfaceDescription -match "Realtek") {
                $vendor = "Realtek"
            }
            elseif ($adapter.InterfaceDescription -match "Qualcomm") {
                $vendor = "Qualcomm"
            }
            elseif ($adapter.InterfaceDescription -match "Killer") {
                $vendor = "Killer"
            }

            if ($adapter.InterfaceDescription -match "Wi-Fi|Wireless|802.11") {
                $type = "WiFi"
            }
            elseif ($adapter.InterfaceDescription -match "Ethernet|LAN") {
                $type = "Ethernet"
            }
            elseif ($adapter.InterfaceDescription -match "Bluetooth") {
                $type = "Bluetooth"
            }

            $adapterInfo = @{
                Name = $adapter.InterfaceDescription
                Vendor = $vendor
                Type = $type
                Status = $adapter.Status
                Speed = $adapter.LinkSpeed
            }

            $adapterList += $adapterInfo
            Write-ColorOutput "  + Found: $($adapter.InterfaceDescription) [$type - $vendor]" "Green"
        }

        return $adapterList
    }
    catch {
        Write-ColorOutput "  X Error detecting network adapters: $_" "Red"
        return @()
    }
}

function Get-SystemInfo {
    Write-ColorOutput "`n[Detecting System Information]" "Cyan"

    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem
        $bios = Get-CimInstance -ClassName Win32_BIOS

        $systemInfo = @{
            Manufacturer = $cs.Manufacturer
            Model = $cs.Model
            BIOSVersion = $bios.SMBIOSBIOSVersion
            TotalMemoryGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        }

        Write-ColorOutput "  + Manufacturer: $($cs.Manufacturer)" "Green"
        Write-ColorOutput "  + Model: $($cs.Model)" "Green"
        Write-ColorOutput "  + BIOS: $($bios.SMBIOSBIOSVersion)" "Green"
        Write-ColorOutput "  + RAM: $($systemInfo.TotalMemoryGB) GB" "Green"

        return $systemInfo
    }
    catch {
        Write-ColorOutput "  X Error detecting system info: $_" "Red"
        return $null
    }
}

function Get-StorageDevices {
    Write-ColorOutput "`n[Detecting Storage Devices]" "Cyan"

    try {
        $disks = Get-PhysicalDisk

        $diskList = @()
        foreach ($disk in $disks) {
            $diskInfo = @{
                Model = $disk.FriendlyName
                MediaType = $disk.MediaType
                SizeGB = [math]::Round($disk.Size / 1GB, 2)
                BusType = $disk.BusType
            }

            $diskList += $diskInfo
            Write-ColorOutput "  + Found: $($disk.FriendlyName) [$($disk.MediaType) - $($diskInfo.SizeGB) GB]" "Green"
        }

        return $diskList
    }
    catch {
        Write-ColorOutput "  X Error detecting storage devices: $_" "Red"
        return @()
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Hardware Detection" "Magenta"
Write-ColorOutput "========================================" "Magenta"

# Collect all hardware information
$hardwareInfo = @{
    System = Get-SystemInfo
    CPU = Get-CPUInfo
    GPU = Get-GPUInfo
    Audio = Get-AudioDevices
    Network = Get-NetworkAdapters
    Storage = Get-StorageDevices
}

# Export to JSON for use by other scripts
$exportPath = Join-Path $PSScriptRoot "..\hardware-info.json"
try {
    $hardwareInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $exportPath -Encoding UTF8
    Write-ColorOutput "`n+ Hardware information exported to: $exportPath" "Green"
}
catch {
    Write-ColorOutput "`nX Failed to export hardware info: $_" "Red"
}

# Summary
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Hardware Detection Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "System: $($hardwareInfo.System.Manufacturer) $($hardwareInfo.System.Model)" "White"
Write-ColorOutput "CPU: $($hardwareInfo.CPU.Name)" "White"
Write-ColorOutput "GPU Count: $($hardwareInfo.GPU.Count)" "White"
Write-ColorOutput "Audio Devices: $($hardwareInfo.Audio.Count)" "White"
Write-ColorOutput "Network Adapters: $($hardwareInfo.Network.Count)" "White"
Write-ColorOutput "Storage Devices: $($hardwareInfo.Storage.Count)" "White"

Write-ColorOutput "`nHardware detection complete!" "Green"

# Return the hardware info object
return $hardwareInfo
