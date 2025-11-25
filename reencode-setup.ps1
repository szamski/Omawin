$content = Get-Content 'setup.ps1' -Raw -Encoding UTF8
[System.IO.File]::WriteAllText((Resolve-Path 'setup.ps1').Path, $content, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Re-encoded setup.ps1 with UTF-8 (no BOM)" -ForegroundColor Green
