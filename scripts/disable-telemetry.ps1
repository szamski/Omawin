# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Disables Windows 11 telemetry, tracking, and privacy-invasive features.

.DESCRIPTION
    Comprehensively disables Microsoft telemetry, diagnostic data collection,
    advertising ID, activity tracking, and other privacy-invasive features.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\disable-telemetry.ps1
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

function Disable-ScheduledTask {
    param(
        [string]$TaskPath,
        [string]$TaskName,
        [string]$Description
    )

    if (Test-DryRun) {
        Write-DryRunAction "Disable scheduled task: $TaskPath\$TaskName - $Description"
        return $true
    }

    try {
        $task = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($task) {
            Disable-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction Stop | Out-Null
            Write-ColorOutput "  + $Description" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  o Task not found (already removed or not present): $TaskName" "Gray"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to disable task $TaskName : $_" "Red"
        return $false
    }
}

function Stop-TelemetryService {
    param(
        [string]$ServiceName,
        [string]$Description
    )

    if (Test-DryRun) {
        Write-DryRunAction "Stop and disable service: $ServiceName - $Description"
        return $true
    }

    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction Stop
            Write-ColorOutput "  + $Description" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  o Service not found: $ServiceName" "Gray"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  X Failed to disable service $ServiceName : $_" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Disable Telemetry and Privacy Tracking" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalSettings = 0

# ========================================
# Disable Telemetry and Diagnostic Data
# ========================================
Write-ColorOutput "`n[Telemetry and Diagnostic Data]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
        -Name "AllowTelemetry" -Value 0 -Type "DWord" `
        -Description "Disable telemetry (requires Enterprise/Education edition for full effect)") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
        -Name "AllowTelemetry" -Value 0 -Type "DWord" `
        -Description "Disable diagnostic data collection") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
        -Name "DoNotShowFeedbackNotifications" -Value 1 -Type "DWord" `
        -Description "Disable feedback notifications") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Siuf\Rules" `
        -Name "NumberOfSIUFInPeriod" -Value 0 -Type "DWord" `
        -Description "Disable feedback experience") {
    $successCount++
}

# ========================================
# Disable Advertising ID & Tracking
# ========================================
Write-ColorOutput "`n[Advertising and Activity Tracking]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
        -Name "Enabled" -Value 0 -Type "DWord" `
        -Description "Disable advertising ID") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" `
        -Name "DisabledByGroupPolicy" -Value 1 -Type "DWord" `
        -Description "Disable advertising ID (group policy)") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
        -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type "DWord" `
        -Description "Disable tailored experiences") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
        -Name "EnableActivityFeed" -Value 0 -Type "DWord" `
        -Description "Disable activity feed") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
        -Name "PublishUserActivities" -Value 0 -Type "DWord" `
        -Description "Disable publishing user activities") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
        -Name "UploadUserActivities" -Value 0 -Type "DWord" `
        -Description "Disable uploading user activities") {
    $successCount++
}

# ========================================
# Disable Cortana & Web Search
# ========================================
Write-ColorOutput "`n[Cortana and Search Privacy]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
        -Name "AllowCortana" -Value 0 -Type "DWord" `
        -Description "Disable Cortana") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
        -Name "DisableWebSearch" -Value 1 -Type "DWord" `
        -Description "Disable web search in Start Menu") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
        -Name "ConnectedSearchUseWeb" -Value 0 -Type "DWord" `
        -Description "Disable connected search") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
        -Name "BingSearchEnabled" -Value 0 -Type "DWord" `
        -Description "Disable Bing search integration") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
        -Name "CortanaConsent" -Value 0 -Type "DWord" `
        -Description "Disable Cortana consent") {
    $successCount++
}

# ========================================
# Disable Location Tracking
# ========================================
Write-ColorOutput "`n[Location Tracking]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
        -Name "DisableLocation" -Value 1 -Type "DWord" `
        -Description "Disable location tracking") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
        -Name "DisableWindowsLocationProvider" -Value 1 -Type "DWord" `
        -Description "Disable Windows location provider") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
        -Name "DisableLocationScripting" -Value 1 -Type "DWord" `
        -Description "Disable location scripting") {
    $successCount++
}

# ========================================
# Disable Cloud Content & Consumer Features
# ========================================
Write-ColorOutput "`n[Cloud Content and Suggestions]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        -Name "ContentDeliveryAllowed" -Value 0 -Type "DWord" `
        -Description "Disable content delivery") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        -Name "SilentInstalledAppsEnabled" -Value 0 -Type "DWord" `
        -Description "Disable silent app installs") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        -Name "SubscribedContent-338393Enabled" -Value 0 -Type "DWord" `
        -Description "Disable suggested content in Settings") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        -Name "SubscribedContent-353694Enabled" -Value 0 -Type "DWord" `
        -Description "Disable suggested content in Settings (2)") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        -Name "SubscribedContent-353696Enabled" -Value 0 -Type "DWord" `
        -Description "Disable suggested content in Settings (3)") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
        -Name "DisableWindowsConsumerFeatures" -Value 1 -Type "DWord" `
        -Description "Disable consumer features (auto-installed apps)") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
        -Name "DisableSoftLanding" -Value 1 -Type "DWord" `
        -Description "Disable Windows spotlight features") {
    $successCount++
}

# ========================================
# Disable Windows Error Reporting
# ========================================
Write-ColorOutput "`n[Windows Error Reporting]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" `
        -Name "Disabled" -Value 1 -Type "DWord" `
        -Description "Disable Windows Error Reporting") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" `
        -Name "Disabled" -Value 1 -Type "DWord" `
        -Description "Disable Windows Error Reporting (policy)") {
    $successCount++
}

# ========================================
# Disable App Diagnostics
# ========================================
Write-ColorOutput "`n[App Diagnostics and Privacy]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
        -Name "AppDiagnosticsDisabled" -Value 1 -Type "DWord" `
        -Description "Disable app diagnostics access") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" `
        -Name "LetAppsAccessAccountInfo" -Value 2 -Type "DWord" `
        -Description "Force deny apps access to account info") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" `
        -Name "LetAppsAccessContacts" -Value 2 -Type "DWord" `
        -Description "Force deny apps access to contacts") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" `
        -Name "LetAppsAccessCalendar" -Value 2 -Type "DWord" `
        -Description "Force deny apps access to calendar") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" `
        -Name "LetAppsAccessCallHistory" -Value 2 -Type "DWord" `
        -Description "Force deny apps access to call history") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" `
        -Name "LetAppsAccessEmail" -Value 2 -Type "DWord" `
        -Description "Force deny apps access to email") {
    $successCount++
}

# ========================================
# Disable Automatic Updates for Other Microsoft Products
# ========================================
Write-ColorOutput "`n[Windows Update Privacy]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
        -Name "NoAutoUpdate" -Value 0 -Type "DWord" `
        -Description "Keep automatic updates enabled (security)") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" `
        -Name "DODownloadMode" -Value 1 -Type "DWord" `
        -Description "Limit Windows Update P2P to local network only") {
    $successCount++
}

# ========================================
# Disable Inventory Collector
# ========================================
Write-ColorOutput "`n[Inventory and Compatibility]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" `
        -Name "DisableInventory" -Value 1 -Type "DWord" `
        -Description "Disable inventory collector") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" `
        -Name "AITEnable" -Value 0 -Type "DWord" `
        -Description "Disable Application Impact Telemetry") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" `
        -Name "DisableUAR" -Value 1 -Type "DWord" `
        -Description "Disable Steps Recorder") {
    $successCount++
}

# ========================================
# Disable Telemetry Services
# ========================================
Write-ColorOutput "`n[Telemetry Services]" "Cyan"

$totalSettings++
if (Stop-TelemetryService -ServiceName "DiagTrack" -Description "Disable Connected User Experiences and Telemetry service") {
    $successCount++
}

$totalSettings++
if (Stop-TelemetryService -ServiceName "dmwappushservice" -Description "Disable Device Management Wireless Application Protocol") {
    $successCount++
}

# ========================================
# Disable Telemetry Scheduled Tasks
# ========================================
Write-ColorOutput "`n[Telemetry Scheduled Tasks]" "Cyan"

$telemetryTasks = @(
    @{ Path = "\Microsoft\Windows\Application Experience\"; Name = "Microsoft Compatibility Appraiser" },
    @{ Path = "\Microsoft\Windows\Application Experience\"; Name = "ProgramDataUpdater" },
    @{ Path = "\Microsoft\Windows\Autochk\"; Name = "Proxy" },
    @{ Path = "\Microsoft\Windows\Customer Experience Improvement Program\"; Name = "Consolidator" },
    @{ Path = "\Microsoft\Windows\Customer Experience Improvement Program\"; Name = "UsbCeip" },
    @{ Path = "\Microsoft\Windows\DiskDiagnostic\"; Name = "Microsoft-Windows-DiskDiagnosticDataCollector" },
    @{ Path = "\Microsoft\Windows\Feedback\Siuf\"; Name = "DmClient" },
    @{ Path = "\Microsoft\Windows\Feedback\Siuf\"; Name = "DmClientOnScenarioDownload" }
)

foreach ($task in $telemetryTasks) {
    $totalSettings++
    if (Disable-ScheduledTask -TaskPath $task.Path -TaskName $task.Name -Description "Disable telemetry task: $($task.Name)") {
        $successCount++
    }
}

# ========================================
# Disable OneDrive Telemetry
# ========================================
Write-ColorOutput "`n[OneDrive Privacy]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" `
        -Name "DisableFileSyncNGSC" -Value 1 -Type "DWord" `
        -Description "Disable OneDrive file sync") {
    $successCount++
}

# ========================================
# Disable Edge Telemetry & Tracking
# ========================================
Write-ColorOutput "`n[Microsoft Edge Privacy]" "Cyan"

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" `
        -Name "MetricsReportingEnabled" -Value 0 -Type "DWord" `
        -Description "Disable Edge metrics reporting") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" `
        -Name "PersonalizationReportingEnabled" -Value 0 -Type "DWord" `
        -Description "Disable Edge personalization reporting") {
    $successCount++
}

$totalSettings++
if (Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" `
        -Name "UserFeedbackAllowed" -Value 0 -Type "DWord" `
        -Description "Disable Edge feedback") {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Privacy Configuration Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total settings: $totalSettings" "White"
Write-ColorOutput "Successfully applied: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSettings - $successCount)" "Red"

if ($successCount -eq $totalSettings) {
    Write-ColorOutput "`nAll privacy settings configured successfully!" "Green"
}
else {
    Write-ColorOutput "`nSome settings could not be applied. Please check the errors above." "Yellow"
}

Write-ColorOutput "`n[Important Notes]" "Yellow"
Write-ColorOutput "  â€˘ Some telemetry settings require Windows Enterprise/Education for full effect" "Gray"
Write-ColorOutput "  â€˘ A system restart is recommended for all changes to take effect" "Gray"
Write-ColorOutput "  â€˘ Some features (like Cortana) may still appear but will be non-functional" "Gray"
Write-ColorOutput "  â€˘ Windows Security and Windows Update remain enabled for your safety" "Gray"
