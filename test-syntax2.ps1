$code = Get-Content setup.ps1 -Raw
$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$tokens, [ref]$errors)

if ($errors.Count -gt 0) {
    $errors | ForEach-Object {
        Write-Host "Line $($_.Extent.StartLineNumber): $($_.Message)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "No syntax errors found!" -ForegroundColor Green
    exit 0
}
