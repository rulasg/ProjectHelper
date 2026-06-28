
Register-ArgumentCompleter -CommandName Edit-ProjectItem -ParameterName Status -ScriptBlock { param($commandName, $parameterName,$wordToComplete) Get-ProjectArgumentCompleter_ParameterNameFieldValues @PsBoundParameters }
Register-ArgumentCompleter -CommandName Edit-ProjectItem -ParameterName FieldName -ScriptBlock { param($commandName, $parameterName, $wordToComplete) Get-ProjectArgumentCompleter_FieldNames @PsBoundParameters }
Register-ArgumentCompleter -CommandName Edit-ProjectItem -ParameterName Value -ScriptBlock { param($commandName, $parameterName, $wordToComplete, $commandAst) Get-ProjectArgumentCompleter_ParseCommandToExtractFieldName_FieldValues @PsBoundParameters }

function Edit-ProjectItem {
    [CmdletBinding()]
    [Alias("epi","e")]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("ProjectOwner")][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName)][string]$ProjectNumber,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][Alias("ItemId")][string]$Id,
        [Parameter(ValueFromPipelineByPropertyName,Position = 1)][Alias("F")][string]$FieldName,
        [Parameter(ValueFromPipelineByPropertyName,Position = 2)][Alias("V")][string]$Value,
        
        [Parameter()][Alias("MM")][switch]$Commit,
        [Parameter()][switch]$Force,
        [Parameter()][Alias("O")][switch]$OpenInBrowser,
        
        # Fields
        [Parameter()][hashtable]$Fields,
        
        # Content
        [Parameter()][Alias("T")][string]$Title,
        [Parameter()][Alias("B")][string]$Body,
        [Parameter()][Alias("BL")][switch]$BodyLongText,
        
        # AddComment
        [Parameter()][Alias("AC")][string]$AddComment,
        [Parameter()][Alias("CL")][switch]$AddCommentLongText,

        # Status
        # [Parameter()][ValidateSet([ValidStatus])][Alias("St")][string]$Status,
        [Parameter()][Alias("St")][string]$Status,

        # Punded parameters
        [Parameter()][Alias("D")][switch]$DefaultValues,
        [Parameter()][switch]$Close,
        [Parameter()][switch]$Backlog,
        [Parameter()][switch]$Ready,

        [Parameter()][switch]$NormalizeTitle
    )

    begin{
        # Resolve project parameters 
        ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

        # Resolve ItemId
        $Id = [string]::IsNullOrWhiteSpace($Id) ? $(Invoke-QQ_Get_G) : $Id

        # Create params
        $params = @{ Owner = $Owner ; ProjectNumber = $ProjectNumber }

        # Force cache update
        if($Force){ Update-Project @params }

        # Centralize the editing of the value for later refactoring if needed
        function edit($params) {
             editProjectItemValue @params
            }
        # Commit check
        if ($commmit) {
            $staged = Get-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber

            if ($staged) {
                $quit = $true
                throw "There are staged items. Please commit or reset them before updating items"
            }
        }

        if( $AddCommentLongText ) {
            $AddComment = Get-LongText -Text $AddComment
        }

        # Default
        if($DefaultValues){
            "DefaultValues EMPTY" | Write-MyDebug -section "Edit-ProjectItem"

            # Do not edit but leave this parameters flow the edit process
        }

        # Close
        if ($Close) {
            $Status = resolveStatus -Owner $Owner -ProjectNumber $ProjectNumber -ConfigKey "CloseStatus" -DefaultValue "Done"

            # Do not edit but leave this parameters flow the edit process
        }

        # Backlog
        if ($Backlog) {
            $Status = resolveStatus -Owner $Owner -ProjectNumber $ProjectNumber -ConfigKey "Status_Backlog" -DefaultValue "Todo"

            # Do not edit but leave this parameters flow the edit process
        }

        # Ready
        if ($Ready) {
            $Status = resolveStatus -Owner $Owner -ProjectNumber $ProjectNumber -ConfigKey "Status_Ready"

            # Do not edit but leave this parameters flow the edit process
        }

    }

    process{

        # Begin determine that we should not run any pipe object
        if( $quit ){ return }

        $params.ItemId = [string]::IsNullOrWhiteSpace($Id) ? $(Invoke-QQ_Get_G) : $Id

        # Status parameter
        if (-Not [string]::IsNullOrWhiteSpace($Status)) {
            $params.fieldname = "Status"
            $params.value = "$Status"
            edit $params
        }

        # Title parameter
        if (-Not [string]::IsNullOrWhiteSpace($Title)) {
            $params.fieldname = "Title"
            $params.value = "$Title"
            edit $params
        }

        # AddComment parameter
        if (-Not [string]::IsNullOrWhiteSpace($AddComment)) {
            $params.fieldname = "AddComment"
            $params.value = "$AddComment"
            edit $params
        }

        # FieldName parameter
        if (-Not [string]::IsNullOrWhiteSpace($FieldName)) {
            $params.FieldName = $FieldName
            $params.Value = $Value
            edit $params
        }

        #Fields
        if ($Fields) {
            foreach ($key in $Fields.Keys) {
                $value = $Fields[$key]
                $params.fieldname = $key
                $params.value = "$value"
                edit $params
            }
        }

        # With Item

        # TODO: BodyLongText does not work properly
        # Body parameter
        # If BodyLongText seed with parameter of actual value
        if( $BodyLongText ) {
            if([string]::IsNullOrWhiteSpace($Body)){
                $item = Get-BaseProjectItem -ItemId $Id -Owner $Owner -ProjectNumber $ProjectNumber
                $body = Get-LongText -Text $item.Body
            } else {
                $body = Get-LongText -Text $Body
            }
        }
        if (-Not [string]::IsNullOrWhiteSpace($Body)) {
            $params.fieldname = "Body"
            $params.value = "$Body"
            edit $params
        }

        if ($OpenInBrowser) {
            $item = Get-BaseProjectItem -ItemId $Id -Owner $Owner -ProjectNumber $ProjectNumber
            if ($null -ne $item) {
                Open-Url -Url $item.url
            } else {
                Write-Warning "Item not found. Cannot open in browser."
            }
        }

        # NormalizeTitle
        if ($NormalizeTitle) {
            $item = Get-BaseProjectItem -ItemId $Id -Owner $Owner -ProjectNumber $ProjectNumber
            $params.fieldname = "Title"
            $params.value = Get-NormalizedTitle -Item $item
            edit $params
        }
    }

    end {
        # If Commit is specified, sync the staged items
        if ($Commit) {
            Sync-ProjectItemStaged -Owner $Owner -ProjectNumber $ProjectNumber
        }

    }
} Export-ModuleMember -Function Edit-ProjectItem -Alias "epi","e"

function Edit-ProjectItemValue {
    [CmdletBinding()]
    [Alias("epiv")]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName)][string]$ProjectNumber,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][Alias("Id")][string]$ItemId,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Url,
        [Parameter(ValueFromPipelineByPropertyName,Position = 1)][string]$FieldName,
        [Parameter(ValueFromPipelineByPropertyName,Position = 2)][string]$Value,
        [Parameter()][switch]$Force
    )

    process{

        $parameters = @{
            Owner = $Owner
            ProjectNumber = $ProjectNumber
            ItemId = $ItemId
            Url = $Url
            FieldName = $FieldName
            Value = $Value
            Force = $Force
        }
        editProjectItemValue @parameters
    }

} Export-ModuleMember -Function Edit-ProjectItemValue -Alias "epiv"

<#
.SYNOPSIS
    Edit a project item
.EXAMPLE
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "comment" -Value "new value of the comment"
    Edit-ProjectItem -Owner "someOwner" -ProjectNumber 164 -Title "Item 1 - title" -FieldName "title" -Value "new value of the title"
#>
function editProjectItemValue {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Owner,
        [Parameter(ValueFromPipelineByPropertyName)][string]$ProjectNumber,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)][Alias("Id")][string]$ItemId,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Url,
        [Parameter(ValueFromPipelineByPropertyName,Position = 1)][string]$FieldName,
        [Parameter(ValueFromPipelineByPropertyName,Position = 2)][string]$Value,
        [Parameter()][switch]$Force
    )

    begin{
        # Resolve project parameters 
        ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber 

        # Force cache update
        # Full sync if force
        $db = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

        $dbDirty= $false
    }

    process{

        # Find the actual value of the item. Item+Staged
        # Ignore $dirty as we are changing the db we will always save
        ($item, $dirty) = Resolve-ProjectItem -Database $db -ItemId $ItemId -Url $Url

        # if the item is not found
        if($null -eq $item){ "Item [$ItemId] not found" | Write-MyError; return }

        # Value transformations
        $valueTransformed = Convertto-ItemTransformedValue -Item $item -Value $Value

        # Check if value is the same
        if ( AreEqual -Object1:$item.$FieldName -Object2:$valueTransformed) {
            "The value is the same, no need to stage it" | Write-Verbose
            return
        }

        # save the new value
        Save-ItemFieldValue $db $itemId $FieldName $valueTransformed
        $dbDirty = $true

    }
    
    end{
        if($dbDirty){
            "Database is dirty, saving changes" | Write-MyDebug -Section "Edit-ProjectItem"
            # Commit changes to the database
            Save-ProjectDatabaseSafe -Database $db
        } else {
            "Database is not dirty, no need to save changes" | Write-MyDebug -Section "Edit-ProjectItem"
        }
    }

} 

# function Get-NormalizedTitle {
#     param(
#         [Parameter(Mandatory)][hashtable]$Item
#     )
#     $title = $Item.Title
#     $header = "[{0}]" -f $Item.RepositoryName

#     if($title.ToLower().Contains($header.ToLower())){
#         "The title is already normalized" | Write-MyDebug -section "Edit-ProjectItem"
#         # update title with proper repository name case
#         $newTitle = $title -replace "^\[[^\]]*\]\s*", "$header"
#         return $newTitle
#     } else {
#         return "$header $title"
#     }
# }

function Get-NormalizedTitle {
    param(
        [Parameter(Mandatory)][hashtable]$Item
    )
    $title = $Item.Title
    $header = "[{0}]" -f $Item.RepositoryName
    $repoEscaped = [regex]::Escape($Item.RepositoryName)
    
    "Original   title: $title" | Write-MyDebug -section "Edit-ProjectItem NormalizedTitle"

    if($title -imatch "\[$repoEscaped\]" -or $title -imatch "^\s*\[?$repoEscaped\]\s*"){
        # Ttile contains repo name. Normalize it to proper case and formatting. This will cover the following scenarios:
        $ret = ($title -ireplace "^\s*\[?$repoEscaped\]\s*", "$header ") -ireplace "\[$repoEscaped\]", $header
        
    } else {
        $ret = "$header $title"
    }

    "Normalized title: $ret" | Write-MyDebug -section "Edit-ProjectItem NormalizedTitle"
    return $ret
}

function resolveStatus{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)][string]$Owner,
        [Parameter(Mandatory,Position=1)][string]$ProjectNumber,
        [Parameter(Mandatory,Position=2)][string]$ConfigKey,
        [Parameter(Position=3)][string]$DefaultValue
        
    )
    $readyfield = Get-ProjectConfigValue -Owner $Owner -ProjectNumber $ProjectNumber -ConfigName "$($configKey)" -DefaultValue "$($DefaultValue)"

    if(-not $readyfield){
        Write-Warning "No $configKey in project configuration. Please use Status parameters to set values or update $configKey in ProjectConfig"
        return ""
    }
      
    return $readyfield
}