<#
.SYNOPSIS
    Installs Scoop package manager and essential development tools.

.DESCRIPTION
    Installs Scoop if not present, then installs gcc and tree-sitter via Scoop.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\install-scoop.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-ScoopInstalled {
    try {
        $null = Get-Command scoop -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-Scoop {
    Write-ColorOutput "`nInstalling Scoop package manager..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install Scoop package manager"
        Write-DryRunAction "Set execution policy for current user"
        Write-DryRunAction "Download and run Scoop installer"
        return $true
    }

    try {
        # Set execution policy for current user
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

        # Download and install Scoop
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

        if (Test-ScoopInstalled) {
            Write-ColorOutput "  + Scoop installed successfully" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X Scoop installation failed" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Failed to install Scoop: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Install-ScoopPackage {
    param(
        [string]$PackageName,
        [string]$Bucket = $null
    )

    Write-ColorOutput "`nInstalling $PackageName via Scoop..." "Cyan"

    if (Test-DryRun) {
        if ($Bucket) {
            Write-DryRunAction "Add Scoop bucket: $Bucket"
        }
        Write-DryRunAction "Install package: $PackageName"
        return $true
    }

    try {
        # Add bucket if specified
        if ($Bucket) {
            Write-ColorOutput "  Adding bucket: $Bucket" "Gray"
            scoop bucket add $Bucket 2>&1 | Out-Null
        }

        # Check if already installed
        $installed = scoop list $PackageName 2>&1
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageName) {
            Write-ColorOutput "  ○ $PackageName is already installed" "Gray"
            return $true
        }

        # Install the package
        Write-ColorOutput "  Installing $PackageName..." "Gray"
        scoop install $PackageName

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ $PackageName installed successfully" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  ✗ Failed to install $PackageName" "Red"
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
Write-ColorOutput "  Scoop Package Manager Setup" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalSteps = 0

# ========================================
# Step 1: Install Scoop
# ========================================
Write-ColorOutput "`n[Step 1: Scoop Installation]" "Cyan"
$totalSteps++

if (Test-ScoopInstalled) {
    Write-ColorOutput "  ○ Scoop is already installed" "Gray"
    $successCount++
}
else {
    if (Install-Scoop) {
        $successCount++
    }
}

# ========================================
# Step 2: Install GCC
# ========================================
Write-ColorOutput "`n[Step 2: GCC Installation]" "Cyan"
$totalSteps++

if (Install-ScoopPackage -PackageName "gcc" -Bucket "main") {
    $successCount++
}

# ========================================
# Step 3: Install tree-sitter
# ========================================
Write-ColorOutput "`n[Step 3: tree-sitter Installation]" "Cyan"
$totalSteps++

if (Install-ScoopPackage -PackageName "tree-sitter") {
    $successCount++
}

# ========================================
# Step 4: Install make (useful with gcc)
# ========================================
Write-ColorOutput "`n[Step 4: make Installation]" "Cyan"
$totalSteps++

if (Install-ScoopPackage -PackageName "make") {
    $successCount++
}

# ========================================
# Step 5: Install grep
# ========================================
Write-ColorOutput "`n[Step 4: make Installation]" "Cyan"
$totalSteps++

if (Install-ScoopPackage -PackageName "grep") {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Scoop Setup Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nScoop setup completed successfully!" "Green"
    Write-ColorOutput "`nInstalled tools:" "White"
    Write-ColorOutput "  • Scoop package manager" "Gray"
    Write-ColorOutput "  • gcc (GNU Compiler Collection)" "Gray"
    Write-ColorOutput "  • tree-sitter (Parser generator)" "Gray"
    Write-ColorOutput "  • make (Build automation)" "Gray"
}
else {
    Write-ColorOutput "`nScoop setup completed with some errors. Please check the output above." "Yellow"
}

Write-ColorOutput "`n[Useful Scoop Commands]" "Cyan"
Write-ColorOutput "  scoop search <package>       # Search for packages" "Gray"
Write-ColorOutput "  scoop install <package>      # Install a package" "Gray"
Write-ColorOutput "  scoop list                   # List installed packages" "Gray"
Write-ColorOutput "  scoop update                 # Update Scoop itself" "Gray"
Write-ColorOutput "  scoop update *               # Update all packages" "Gray"

