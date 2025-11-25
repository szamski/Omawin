<#
.SYNOPSIS
    Common helper functions shared across all setup scripts.

.DESCRIPTION
    Provides reusable functions for logging, dry-run mode detection, and output formatting.
#>

function Test-DryRunMode {
    <#
    .SYNOPSIS
        Checks if the script is running in dry-run mode.

    .DESCRIPTION
        Returns $true if DRYRUN_MODE environment variable is set to "true".
    #>
    return ($env:DRYRUN_MODE -eq "true")
}

function Write-ColorOutput {
    <#
    .SYNOPSIS
        Writes colored output to the console.

    .PARAMETER Message
        The message to display.

    .PARAMETER Color
        The color to use (default: White).
    #>
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-DryRunAction {
    <#
    .SYNOPSIS
        Writes a dry-run action message.

    .PARAMETER Action
        The action that would be performed.

    .DESCRIPTION
        Displays what would happen in dry-run mode with [DRY-RUN] prefix.
    #>
    param(
        [string]$Action
    )
    Write-ColorOutput "  [DRY-RUN] Would: $Action" "Cyan"
}

function Invoke-WithDryRun {
    <#
    .SYNOPSIS
        Executes a command or displays dry-run message.

    .PARAMETER Description
        Description of the action.

    .PARAMETER ScriptBlock
        The script block to execute (only if not in dry-run mode).

    .EXAMPLE
        Invoke-WithDryRun -Description "Install package" -ScriptBlock { winget install Git.Git }
    #>
    param(
        [string]$Description,
        [scriptblock]$ScriptBlock
    )

    if (Test-DryRunMode) {
        Write-DryRunAction $Description
        return $true
    }
    else {
        try {
            & $ScriptBlock
            return $true
        }
        catch {
            Write-ColorOutput "  ✗ Error: $(<#
.SYNOPSIS
    Common helper functions shared across all setup scripts.

.DESCRIPTION
    Provides reusable functions for logging, dry-run mode detection, and output formatting.
#>

function Test-DryRunMode {
    <#
    .SYNOPSIS
        Checks if the script is running in dry-run mode.

    .DESCRIPTION
        Returns $true if DRYRUN_MODE environment variable is set to "true".
    #>
    return ($env:DRYRUN_MODE -eq "true")
}

function Write-ColorOutput {
    <#
    .SYNOPSIS
        Writes colored output to the console.

    .PARAMETER Message
        The message to display.

    .PARAMETER Color
        The color to use (default: White).
    #>
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-DryRunAction {
    <#
    .SYNOPSIS
        Writes a dry-run action message.

    .PARAMETER Action
        The action that would be performed.

    .DESCRIPTION
        Displays what would happen in dry-run mode with [DRY-RUN] prefix.
    #>
    param(
        [string]$Action
    )
    Write-ColorOutput "  [DRY-RUN] Would: $Action" "Cyan"
}

function Invoke-WithDryRun {
    <#
    .SYNOPSIS
        Executes a command or displays dry-run message.

    .PARAMETER Description
        Description of the action.

    .PARAMETER ScriptBlock
        The script block to execute (only if not in dry-run mode).

    .EXAMPLE
        Invoke-WithDryRun -Description "Install package" -ScriptBlock { winget install Git.Git }
    #>
    param(
        [string]$Description,
        [scriptblock]$ScriptBlock
    )

    if (Test-DryRunMode) {
        Write-DryRunAction $Description
        return $true
    }
    else {
        try {
            & $ScriptBlock
            return $true
        }
        catch {
            Write-ColorOutput "  ✗ Error: $_" "Red"
            return $false
        }
    }
}
.Exception.Message)" "Red"
            return $false
        }
    }
}

