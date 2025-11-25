# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Installs software packages using winget based on configuration file.

.DESCRIPTION
    Reads software.json configuration and installs all specified packages using Windows Package Manager (winget).
    Provides progress tracking and error handling for each installation.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.PARAMETER ConfigPath
    Path to the software.json configuration file.

.EXAMPLE
    .\install-software.ps1 -ConfigPath "..\config\software.json"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "$PSScriptRoot\..\config\software.json"
)

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WingetInstalled {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-Winget {
    Write-ColorOutput "Installing Windows Package Manager (winget)..." "Yellow"

    try {
        # Install App Installer from Microsoft Store (contains winget)
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        Write-ColorOutput "Winget installed successfully!" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Failed to install winget: $(# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Installs software packages using winget based on configuration file.

.DESCRIPTION
    Reads software.json configuration and installs all specified packages using Windows Package Manager (winget).
    Provides progress tracking and error handling for each installation.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.PARAMETER ConfigPath
    Path to the software.json configuration file.

.EXAMPLE
    .\install-software.ps1 -ConfigPath "..\config\software.json"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "$PSScriptRoot\..\config\software.json"
)

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WingetInstalled {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-Winget {
    Write-ColorOutput "Installing Windows Package Manager (winget)..." "Yellow"

    try {
        # Install App Installer from Microsoft Store (contains winget)
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        Write-ColorOutput "Winget installed successfully!" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Failed to install winget: $_" "Red"
        Write-ColorOutput "Please install App Installer from Microsoft Store manually." "Yellow"
        return $false
    }
}

function Install-Package {
    param(
        [string]$PackageId,
        [string]$PackageName
    )

    Write-ColorOutput "`nInstalling $PackageName ($PackageId)..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install package: $PackageName ($PackageId) using winget"
        return $true
    }

    try {
        # Check if package is already installed
        $installed = winget list --id $PackageId --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
            Write-ColorOutput "  + $PackageName is already installed" "Gray"
            return $true
        }

        # Install the package
        winget install --id $PackageId --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $PackageName installed successfully" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $PackageName (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing ${PackageName}: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Software Installation Script" "Magenta"
if (Test-DryRun) {
    Write-ColorOutput "  [DRY-RUN MODE]" "Cyan"
}
Write-ColorOutput "========================================" "Magenta"

# Check if winget is installed
if (Test-DryRun) {
    Write-ColorOutput "`n[DRY-RUN] Skipping winget check" "Cyan"
}
elseif (-not (Test-WingetInstalled)) {
    Write-ColorOutput "`nWindows Package Manager (winget) is not installed." "Yellow"
    if (-not (Install-Winget)) {
        Write-ColorOutput "`nCannot continue without winget. Exiting..." "Red"
        exit 1
    }
}

if (-not (Test-DryRun)) {
    Write-ColorOutput "`nWinget is available. Proceeding with installations..." "Green"
}
else {
    Write-ColorOutput "`n[DRY-RUN] Showing what would be installed..." "Cyan"
}

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    Write-ColorOutput "`nConfiguration file not found: $ConfigPath" "Red"
    exit 1
}

try {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
}
catch {
    Write-ColorOutput "`nFailed to parse configuration file: $_" "Red"
    exit 1
}

# Install packages by category
$totalPackages = 0
$installedPackages = 0
$failedPackages = @()

foreach ($category in $config.categories.PSObject.Properties) {
    $categoryName = $category.Name
    $categoryData = $category.Value

    Write-ColorOutput "`n========================================" "Magenta"
    Write-ColorOutput "  Category: $categoryName" "Magenta"
    Write-ColorOutput "  $($categoryData.description)" "Gray"
    Write-ColorOutput "========================================" "Magenta"

    foreach ($package in $categoryData.packages) {
        $totalPackages++

        if (Install-Package -PackageId $package.id -PackageName $package.name) {
            $installedPackages++
        }
        else {
            $failedPackages += $package.name
        }

        # Small delay to prevent overwhelming the system
        Start-Sleep -Milliseconds 500
    }
}

# Summary
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total packages: $totalPackages" "White"
Write-ColorOutput "Successfully installed/verified: $installedPackages" "Green"
Write-ColorOutput "Failed: $($failedPackages.Count)" "Red"

if ($failedPackages.Count -gt 0) {
    Write-ColorOutput "`nFailed packages:" "Red"
    foreach ($pkg in $failedPackages) {
        Write-ColorOutput "  - $pkg" "Red"
    }
}

Write-ColorOutput "`nSoftware installation complete!" "Green"
.Exception.Message)" "Red"
        Write-ColorOutput "Please install App Installer from Microsoft Store manually." "Yellow"
        return $false
    }
}

function Install-Package {
    param(
        [string]$PackageId,
        [string]$PackageName
    )

    Write-ColorOutput "`nInstalling $PackageName ($PackageId)..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install package: $PackageName ($PackageId) using winget"
        return $true
    }

    try {
        # Check if package is already installed
        $installed = winget list --id $PackageId --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
            Write-ColorOutput "  + $PackageName is already installed" "Gray"
            return $true
        }

        # Install the package
        winget install --id $PackageId --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $PackageName installed successfully" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $PackageName (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing ${PackageName}: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Software Installation Script" "Magenta"
if (Test-DryRun) {
    Write-ColorOutput "  [DRY-RUN MODE]" "Cyan"
}
Write-ColorOutput "========================================" "Magenta"

# Check if winget is installed
if (Test-DryRun) {
    Write-ColorOutput "`n[DRY-RUN] Skipping winget check" "Cyan"
}
elseif (-not (Test-WingetInstalled)) {
    Write-ColorOutput "`nWindows Package Manager (winget) is not installed." "Yellow"
    if (-not (Install-Winget)) {
        Write-ColorOutput "`nCannot continue without winget. Exiting..." "Red"
        exit 1
    }
}

if (-not (Test-DryRun)) {
    Write-ColorOutput "`nWinget is available. Proceeding with installations..." "Green"
}
else {
    Write-ColorOutput "`n[DRY-RUN] Showing what would be installed..." "Cyan"
}

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    Write-ColorOutput "`nConfiguration file not found: $ConfigPath" "Red"
    exit 1
}

try {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
}
catch {
    Write-ColorOutput "`nFailed to parse configuration file: $(# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Installs software packages using winget based on configuration file.

.DESCRIPTION
    Reads software.json configuration and installs all specified packages using Windows Package Manager (winget).
    Provides progress tracking and error handling for each installation.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.PARAMETER ConfigPath
    Path to the software.json configuration file.

.EXAMPLE
    .\install-software.ps1 -ConfigPath "..\config\software.json"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "$PSScriptRoot\..\config\software.json"
)

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-WingetInstalled {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-Winget {
    Write-ColorOutput "Installing Windows Package Manager (winget)..." "Yellow"

    try {
        # Install App Installer from Microsoft Store (contains winget)
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        Write-ColorOutput "Winget installed successfully!" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Failed to install winget: $_" "Red"
        Write-ColorOutput "Please install App Installer from Microsoft Store manually." "Yellow"
        return $false
    }
}

function Install-Package {
    param(
        [string]$PackageId,
        [string]$PackageName
    )

    Write-ColorOutput "`nInstalling $PackageName ($PackageId)..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install package: $PackageName ($PackageId) using winget"
        return $true
    }

    try {
        # Check if package is already installed
        $installed = winget list --id $PackageId --exact 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
            Write-ColorOutput "  + $PackageName is already installed" "Gray"
            return $true
        }

        # Install the package
        winget install --id $PackageId --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + $PackageName installed successfully" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Failed to install $PackageName (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error installing ${PackageName}: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Software Installation Script" "Magenta"
if (Test-DryRun) {
    Write-ColorOutput "  [DRY-RUN MODE]" "Cyan"
}
Write-ColorOutput "========================================" "Magenta"

# Check if winget is installed
if (Test-DryRun) {
    Write-ColorOutput "`n[DRY-RUN] Skipping winget check" "Cyan"
}
elseif (-not (Test-WingetInstalled)) {
    Write-ColorOutput "`nWindows Package Manager (winget) is not installed." "Yellow"
    if (-not (Install-Winget)) {
        Write-ColorOutput "`nCannot continue without winget. Exiting..." "Red"
        exit 1
    }
}

if (-not (Test-DryRun)) {
    Write-ColorOutput "`nWinget is available. Proceeding with installations..." "Green"
}
else {
    Write-ColorOutput "`n[DRY-RUN] Showing what would be installed..." "Cyan"
}

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    Write-ColorOutput "`nConfiguration file not found: $ConfigPath" "Red"
    exit 1
}

try {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
}
catch {
    Write-ColorOutput "`nFailed to parse configuration file: $_" "Red"
    exit 1
}

# Install packages by category
$totalPackages = 0
$installedPackages = 0
$failedPackages = @()

foreach ($category in $config.categories.PSObject.Properties) {
    $categoryName = $category.Name
    $categoryData = $category.Value

    Write-ColorOutput "`n========================================" "Magenta"
    Write-ColorOutput "  Category: $categoryName" "Magenta"
    Write-ColorOutput "  $($categoryData.description)" "Gray"
    Write-ColorOutput "========================================" "Magenta"

    foreach ($package in $categoryData.packages) {
        $totalPackages++

        if (Install-Package -PackageId $package.id -PackageName $package.name) {
            $installedPackages++
        }
        else {
            $failedPackages += $package.name
        }

        # Small delay to prevent overwhelming the system
        Start-Sleep -Milliseconds 500
    }
}

# Summary
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total packages: $totalPackages" "White"
Write-ColorOutput "Successfully installed/verified: $installedPackages" "Green"
Write-ColorOutput "Failed: $($failedPackages.Count)" "Red"

if ($failedPackages.Count -gt 0) {
    Write-ColorOutput "`nFailed packages:" "Red"
    foreach ($pkg in $failedPackages) {
        Write-ColorOutput "  - $pkg" "Red"
    }
}

Write-ColorOutput "`nSoftware installation complete!" "Green"
.Exception.Message)" "Red"
    exit 1
}

# Install packages by category
$totalPackages = 0
$installedPackages = 0
$failedPackages = @()

foreach ($category in $config.categories.PSObject.Properties) {
    $categoryName = $category.Name
    $categoryData = $category.Value

    Write-ColorOutput "`n========================================" "Magenta"
    Write-ColorOutput "  Category: $categoryName" "Magenta"
    Write-ColorOutput "  $($categoryData.description)" "Gray"
    Write-ColorOutput "========================================" "Magenta"

    foreach ($package in $categoryData.packages) {
        $totalPackages++

        if (Install-Package -PackageId $package.id -PackageName $package.name) {
            $installedPackages++
        }
        else {
            $failedPackages += $package.name
        }

        # Small delay to prevent overwhelming the system
        Start-Sleep -Milliseconds 500
    }
}

# Summary
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total packages: $totalPackages" "White"
Write-ColorOutput "Successfully installed/verified: $installedPackages" "Green"
Write-ColorOutput "Failed: $($failedPackages.Count)" "Red"

if ($failedPackages.Count -gt 0) {
    Write-ColorOutput "`nFailed packages:" "Red"
    foreach ($pkg in $failedPackages) {
        Write-ColorOutput "  - $pkg" "Red"
    }
}

Write-ColorOutput "`nSoftware installation complete!" "Green"

