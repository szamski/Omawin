$errors = @()
[void][System.Management.Automation.PSParser]::Tokenize((Get-Content setup.ps1 -Raw), [ref]$errors)
if ($errors.Count -gt 0) {
    $errors | ForEach-Object {
        Write-Host "Line $($_.Token.StartLine): $($_.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "No syntax errors found" -ForegroundColor Green
}
