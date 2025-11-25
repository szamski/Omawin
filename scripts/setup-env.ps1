# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Configures environment variables and PATH settings.

.DESCRIPTION
    Sets up custom environment variables and adds necessary paths to system and user PATH.
    Based on the current system configuration analysis.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\setup-env.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Add-ToPath {
    param(
        [string]$PathToAdd,
        [string]$Scope = "User"  # "User" or "Machine"
    )

    if (Test-DryRun) {
        Write-DryRunAction "Add to $Scope PATH: $PathToAdd"
        return $true
    }

    try {
        # Get current PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Scope)

        # Check if path already exists
        $pathArray = $currentPath -split ';' | Where-Object { $_ -ne '' }

        if ($pathArray -contains $PathToAdd) {
            Write-ColorOutput "  o $PathToAdd already in $Scope PATH" "Gray"
            return $true
        }

        # Add to PATH
        $newPath = $currentPath.TrimEnd(';') + ';' + $PathToAdd
        [Environment]::SetEnvironmentVariable("PATH", $newPath, $Scope)

        Write-ColorOutput "  + Added $PathToAdd to $Scope PATH" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  X Failed to add $PathToAdd to $Scope PATH: $_" "Red"
        return $false
    }
}

function Set-CustomEnvironmentVariable {
    param(
        [string]$Name,
        [string]$Value,
        [string]$Scope = "User"
    )

    if (Test-DryRun) {
        Write-DryRunAction "Set $Scope environment variable: $Name = $Value"
        return $true
    }

    try {
        $currentValue = [Environment]::GetEnvironmentVariable($Name, $Scope)

        if ($currentValue -eq $Value) {
            Write-ColorOutput "  o $Name is already set to $Value" "Gray"
            return $true
        }

        [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
        Write-ColorOutput "  + Set $Name = $Value" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  X Failed to set $Name : $_" "Red"
        return $false
    }
}

function Refresh-EnvironmentVariables {
    # Refresh environment variables in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Environment Variables Setup" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalOperations = 0

# ========================================
# Custom Environment Variables
# ========================================
Write-ColorOutput "`n[Custom Environment Variables]" "Cyan"

$totalOperations++
if (Set-CustomEnvironmentVariable -Name "Claude_Code" -Value "$env:USERPROFILE\.local\bin" -Scope "User") {
    $successCount++
}

$totalOperations++
if (Set-CustomEnvironmentVariable -Name "NODE_HOME" -Value "C:\Program Files\nodejs" -Scope "Machine") {
    $successCount++
}

# ========================================
# User PATH Additions
# ========================================
Write-ColorOutput "`n[User PATH Additions]" "Cyan"

$userPaths = @(
    "$env:USERPROFILE\.local\bin",                              # Claude Code
    "$env:USERPROFILE\AppData\Roaming\npm",                     # npm global packages
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin",         # VS Code CLI
    "$env:LOCALAPPDATA\Programs\Python\Python313\Scripts",      # Python Scripts
    "$env:LOCALAPPDATA\Programs\Python\Python313"               # Python
)

foreach ($path in $userPaths) {
    $totalOperations++
    if (Add-ToPath -PathToAdd $path -Scope "User") {
        $successCount++
    }
}

# ========================================
# System PATH Additions
# ========================================
Write-ColorOutput "`n[System PATH Additions]" "Cyan"

$systemPaths = @(
    "C:\Program Files\Git\cmd",                                 # Git
    "C:\Program Files\starship\bin",                            # Starship
    "C:\Program Files\nodejs",                                  # Node.js
    "C:\Program Files\Docker\Docker\resources\bin"              # Docker
)

foreach ($path in $systemPaths) {
    $totalOperations++
    if (Add-ToPath -PathToAdd $path -Scope "Machine") {
        $successCount++
    }
}

# ========================================
# Refresh Environment
# ========================================
Write-ColorOutput "`n[Refreshing Environment]" "Cyan"
try {
    Refresh-EnvironmentVariables
    Write-ColorOutput "  + Environment variables refreshed in current session" "Green"
}
catch {
    Write-ColorOutput "  X Failed to refresh environment: $_" "Red"
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Environment Setup Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total operations: $totalOperations" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalOperations - $successCount)" "Red"

if ($successCount -eq $totalOperations) {
    Write-ColorOutput "`nAll environment variables configured successfully!" "Green"
}
else {
    Write-ColorOutput "`nSome environment variables could not be set. Please check the errors above." "Yellow"
}

Write-ColorOutput "`nNote: You may need to restart your terminal or system for all changes to take effect." "Yellow"

# Display current PATH for verification
Write-ColorOutput "`n[Current PATH Preview]" "Cyan"
Write-ColorOutput "User PATH entries:" "White"
$userPathEntries = [Environment]::GetEnvironmentVariable("PATH", "User") -split ';' | Where-Object { $_ -ne '' }
$userPathEntries | ForEach-Object { Write-ColorOutput "  - $_" "Gray" }
