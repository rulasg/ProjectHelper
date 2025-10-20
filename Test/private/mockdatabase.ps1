
$folderName = "test_database_path"
function Mock_DatabaseRoot([switch]$NotReset){

    # Check if the database path exists
    if (-Not (Test-Path -Path $folderName -PathType Container)) {
        New-Item -Path $folderName -ItemType Directory -Force | Out-Null
    }

    $fullpath = $folderName | Convert-path

    MockCallToString "Invoke-ProjectHelperGetDatabaseStorePath" -OutString $fullpath

    #check $NotReset
    if(-Not $NotReset){
        Reset-DatabaseStore
    }
}

function Get-Mock_DatabaseRootPath{

    return $folderName | Convert-Path

}

