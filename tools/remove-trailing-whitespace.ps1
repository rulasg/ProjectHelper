# Script to remove trailing whitespace from PowerShell files
# This addresses the PSAvoidTrailingWhitespace rule in PSScriptAnalyzer

Write-Host "Removing trailing whitespace and trailing empty lines from files..." -ForegroundColor Green

# Get all PowerShell files recursively
$files = Get-ChildItem -Path . -Include *.ps1, *.psm1, *.psd1 -Recurse

$count = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw

    # Replace trailing whitespace on each line
    $newContent = $content -replace '[ \t]+\r?\n', "`n"

    # Remove trailing empty lines at the end of the file
    $newContent = $newContent -replace '(\r?\n)+$', "`n"

    # Check if content changed
    if ($newContent -ne $content) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        $count++
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "Done! Fixed trailing whitespace and empty lines in $count files." -ForegroundColor Green
