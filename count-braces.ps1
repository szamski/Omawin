$content = Get-Content setup.ps1 -Raw
$openCount = ([regex]::Matches($content, '\{')).Count
$closeCount = ([regex]::Matches($content, '\}')).Count
Write-Host "Open braces: $openCount"
Write-Host "Close braces: $closeCount"
Write-Host "Difference: $($openCount - $closeCount)"
