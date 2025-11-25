# Note: This script should be run as Administrator for full functionality

<#
.SYNOPSIS
    Configures Git and GitHub settings.

.DESCRIPTION
    Sets up Git global configuration including user name, email, SSH keys, and GitHub CLI authentication.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\configure-git.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-GitInstalled {
    try {
        $null = Get-Command git -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-GitHubCLIInstalled {
    try {
        $null = Get-Command gh -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Set-GitConfig {
    param(
        [string]$Key,
        [string]$Value,
        [string]$Description
    )

    if (Test-DryRun) {
        Write-DryRunAction "Set git config: $Key = $Value"
        return $true
    }

    try {
        git config --global $Key $Value
        Write-ColorOutput "  + $Description" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  X Failed to set ${Key}: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Get-GitConfig {
    param([string]$Key)

    try {
        $value = git config --global --get $Key 2>$null
        return $value
    }
    catch {
        return $null
    }
}

function New-SSHKey {
    param(
        [string]$Email
    )

    Write-ColorOutput "`nGenerating SSH key for GitHub..." "Cyan"

    $sshDir = "$env:USERPROFILE\.ssh"
    $keyPath = "$sshDir\id_ed25519"

    if (Test-Path $keyPath) {
        Write-ColorOutput "  o SSH key already exists at: $keyPath" "Gray"
        return $true
    }

    if (Test-DryRun) {
        Write-DryRunAction "Generate SSH key: ssh-keygen -t ed25519 -C $Email"
        Write-DryRunAction "Start SSH agent and add key"
        return $true
    }

    try {
        # Create .ssh directory if it doesn't exist
        if (-not (Test-Path $sshDir)) {
            New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        }

        # Generate SSH key
        ssh-keygen -t ed25519 -C $Email -f $keyPath -N """"

        # Start SSH agent and add key
        Start-Service ssh-agent
        ssh-add $keyPath

        Write-ColorOutput "  + SSH key generated successfully" "Green"
        Write-ColorOutput "`n  Your public key:" "Cyan"
        Get-Content "$keyPath.pub" | Write-Host -ForegroundColor Yellow
        Write-ColorOutput "`n  Add this key to GitHub: https://github.com/settings/keys" "Cyan"

        return $true
    }
    catch {
        Write-ColorOutput "  X Failed to generate SSH key: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Initialize-GitHubCLI {
    Write-ColorOutput "`nConfiguring GitHub CLI..." "Cyan"

    if (-not (Test-GitHubCLIInstalled)) {
        Write-ColorOutput "  o GitHub CLI (gh) is not installed" "Gray"
        Write-ColorOutput "  Install with: winget install --id GitHub.cli" "Yellow"
        return $false
    }

    if (Test-DryRun) {
        Write-DryRunAction "Authenticate with GitHub CLI: gh auth login"
        return $true
    }

    # Check if already authenticated
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "  + Already authenticated with GitHub CLI" "Green"
        return $true
    }

    Write-ColorOutput "  Starting GitHub CLI authentication..." "Yellow"
    Write-ColorOutput "  Please follow the prompts to authenticate with GitHub" "Cyan"

    try {
        gh auth login --web --git-protocol ssh

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  + GitHub CLI authenticated successfully" "Green"
            return $true
        }
        else {
            Write-ColorOutput "  X GitHub CLI authentication failed" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  X Error during GitHub CLI authentication: $($_.Exception.Message)" "Red"
        return $false
    }
}

# ========================================
# Main execution
# ========================================
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Git & GitHub Configuration" "Magenta"
Write-ColorOutput "========================================" "Magenta"

# Check if Git is installed
if (-not (Test-GitInstalled)) {
    Write-ColorOutput "`nX Git is not installed!" "Red"
    Write-ColorOutput "  Please install Git first: winget install --id Git.Git" "Yellow"
    exit 1
}

Write-ColorOutput "`n+ Git is installed" "Green"

$totalSteps = 0
$successCount = 0

# ========================================
# Step 1: Configure Git User
# ========================================
Write-ColorOutput "`n[Step 1: Git User Configuration]" "Cyan"
$totalSteps++

# Check if user info is already configured
$currentName = Get-GitConfig "user.name"
$currentEmail = Get-GitConfig "user.email"

if ($currentName -and $currentEmail) {
    Write-ColorOutput "  o Git user already configured:" "Gray"
    Write-ColorOutput "    Name:  $currentName" "Gray"
    Write-ColorOutput "    Email: $currentEmail" "Gray"

    if (-not (Test-DryRun)) {
        $response = Read-Host "  Keep current settings? (Y/n)"
        if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
            Write-ColorOutput "  + Keeping current Git configuration" "Green"
            $successCount++
        }
        else {
            $name = Read-Host "  Enter your name"
            $email = Read-Host "  Enter your email"

            if (Set-GitConfig "user.name" $name "Set user name: $name") {
                if (Set-GitConfig "user.email" $email "Set user email: $email") {
                    $successCount++
                }
            }
        }
    }
    else {
        Write-DryRunAction "Git user already configured, would prompt to keep or change"
        $successCount++
    }
}
else {
    if (Test-DryRun) {
        Write-DryRunAction "Prompt for Git user name and email"
        Write-DryRunAction "Set git config user.name"
        Write-DryRunAction "Set git config user.email"
        $successCount++
    }
    else {
        Write-ColorOutput "  Git user not configured yet" "Yellow"
        $name = Read-Host "  Enter your name"
        $email = Read-Host "  Enter your email"

        if (Set-GitConfig "user.name" $name "Set user name: $name") {
            if (Set-GitConfig "user.email" $email "Set user email: $email") {
                $successCount++
            }
        }
    }
}

# ========================================
# Step 2: Configure Git Settings
# ========================================
Write-ColorOutput "`n[Step 2: Git Global Settings]" "Cyan"
$totalSteps++

$settingsApplied = 0
$settingsTotal = 9

# Core settings
if (Set-GitConfig "core.autocrlf" "true" "Enable auto CRLF conversion (Windows)") { $settingsApplied++ }
if (Set-GitConfig "core.editor" "code --wait" "Set VS Code as default editor") { $settingsApplied++ }
if (Set-GitConfig "init.defaultBranch" "main" "Set default branch to 'main'") { $settingsApplied++ }

# Pull/Push settings
if (Set-GitConfig "pull.rebase" "false" "Use merge for pull (not rebase)") { $settingsApplied++ }
if (Set-GitConfig "push.autoSetupRemote" "true" "Auto-setup remote on push") { $settingsApplied++ }

# Diff/Merge settings
if (Set-GitConfig "diff.tool" "vscode" "Set VS Code as diff tool") { $settingsApplied++ }
if (Set-GitConfig "merge.tool" "vscode" "Set VS Code as merge tool") { $settingsApplied++ }

# Security
if (Set-GitConfig "credential.helper" "manager" "Use Git Credential Manager") { $settingsApplied++ }
if (Set-GitConfig "gpg.format" "ssh" "Use SSH for GPG signing") { $settingsApplied++ }

if ($settingsApplied -eq $settingsTotal) {
    $successCount++
}

# ========================================
# Step 3: SSH Key Generation
# ========================================
Write-ColorOutput "`n[Step 3: SSH Key for GitHub]" "Cyan"
$totalSteps++

if (Test-DryRun) {
    Write-DryRunAction "Check for existing SSH key"
    Write-DryRunAction "Generate SSH key if needed"
    $successCount++
}
else {
    $email = Get-GitConfig "user.email"
    if ($email) {
        if (New-SSHKey -Email $email) {
            $successCount++
        }
    }
    else {
        Write-ColorOutput "  X No email configured, skipping SSH key generation" "Red"
    }
}

# ========================================
# Step 4: GitHub CLI Authentication
# ========================================
Write-ColorOutput "`n[Step 4: GitHub CLI Authentication]" "Cyan"
$totalSteps++

if (Initialize-GitHubCLI) {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Git Configuration Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "Cyan"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nAll Git configuration steps completed successfully!" "Green"
}
else {
    Write-ColorOutput "`nGit configuration completed with some warnings." "Yellow"
}

Write-ColorOutput "`n[Next Steps]" "Cyan"
Write-ColorOutput "  1. If you generated a new SSH key, add it to GitHub:" "Gray"
Write-ColorOutput "     https://github.com/settings/keys" "Yellow"
Write-ColorOutput "  2. Test your SSH connection:" "Gray"
Write-ColorOutput "     ssh -T git@github.com" "Yellow"
Write-ColorOutput "  3. Clone a repository to test:" "Gray"
Write-ColorOutput "     git clone git@github.com:username/repo.git" "Yellow"
