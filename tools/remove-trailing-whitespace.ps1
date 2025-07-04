# Script to remove trailing whitespace from PowerShell files
# This addresses the PSAvoidTrailingWhitespace rule in PSScriptAnalyzer

Write-Host "Removing trailing whitespace from files..." -ForegroundColor Green

# Get all PowerShell files recursively
$files = Get-ChildItem -Path . -Include *.ps1, *.psm1, *.psd1 -Recurse

$count = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw

    # Replace trailing whitespace with nothing
    $newContent = $content -replace '[ \t]+\r?\n', "`n"

    # Check if content changed
    if ($newContent -ne $content) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        $count++
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "Done! Fixed trailing whitespace in $count files." -ForegroundColor Green
