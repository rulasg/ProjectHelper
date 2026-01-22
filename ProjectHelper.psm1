Write-Information -Message ("Loading {0} ..." -f ($PSCommandPath | Split-Path -LeafBase)) -InformationAction continue

#Module path is where resides the RootModule file. This file. :)
$MODULE_PATH = $PSScriptRoot

# Load ps1 files on code folders in order
"config","helper","include","private","public" | ForEach-Object {
    foreach ($import in Get-ChildItem -Path $MODULE_PATH\$_\*.ps1 -Recurse -ErrorAction SilentlyContinue) {
        try { . $import.fullname }
        catch { Write-Error -Message "Failed to import $($import.fullname): $_" }
    }
}
