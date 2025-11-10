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

function Update-Mock_DatabaseFileWithReplace([string]$FileName, [string]$SearchString, [string]$ReplaceString){
    $dbpath = Get-Mock_DatabaseRootPath | Join-Path -ChildPath $FileName
    $content = Get-Content $dbpath
    $content = $content -replace $SearchString, $ReplaceString
    $content | Set-Content $dbpath
}