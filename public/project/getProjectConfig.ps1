
$SUMMARY_NAME = "ProjectHelper_Configuration"

function Get-ProjectConfigValue{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Mandatory,Position=0)][string]$ConfigName,
        [Parameter()][string]$DefaultValue,
        [switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    "[Get-ProjectConfigValue] Getting project configuraiton value [$ConfigName] for [$Owner/$ProjectNumber] and Force=$Force >>>" | Write-MyDebug -Section "ProjectConfig"

    $config = Get-ProjectConfig -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force

    $actualValue = $config.$ConfigName

    $ret = $actualValue ?? $([string]::IsNullOrEmpty($DefaultValue) ? $null : $defaultValue)

    "[Get-ProjectConfigValue] Getting project configuraiton value [$ConfigName] for [$Owner/$ProjectNumber] and Force=$Force <<<" | Write-MyDebug -Section "ProjectConfig" -Object $ret

    return $ret
}

function Get-ProjectConfigDefaults {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $ret = $DEFAULT_CONFIG_VALUES

    return $ret
} Export-ModuleMember -Function Get-ProjectConfigDefaults

function Get-ProjectConfig {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    "[Get-ProjectConfig] Getting project configuraiton for [$Owner/$ProjectNumber] and Force=$Force >>>" | Write-MyDebug -Section "ProjectConfig"
    
    $p = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems
    
    $readme = $p.readme
    
    # Extract config json from readme
    $config = Get-ProjectConfigFromReadme -Readme $readme
    
    "[Get-ProjectConfig] Getting project configuraiton for [$Owner/$ProjectNumber] and Force=$Force <<<" | Write-MyDebug -Section "ProjectConfig" -Object $config
   
    return $config
} Export-ModuleMember -Function Get-ProjectConfig

function Set-ProjectConfig {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter(Position = 0)][hashtable]$Config,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    "[Set-ProjectConfig] Setting project configuraiton for [$Owner/$ProjectNumber] >>>" | Write-MyDebug -Section "ProjectConfig"
    
    $p = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems
    $readme = $p.readme
    
    # Update the readme with the new config json
    $newReadMe = Merge-ConfigToString -Config $config -ReadMe $readme
    
    if([string]::IsNullOrWhiteSpace($newReadMe)){
        "[Set-ProjectConfig] ERROR: Failed to merge config to readme. New readme is empty or whitespace. Aborting update." | Write-MyDebug -Section "ProjectConfig"
        return $false
    }
    
    # Edit project with new readme
    $ret = Edit-Project -Owner $Owner -ProjectNumber $ProjectNumber -Readme $newReadMe
    
    "[Set-ProjectConfig] Setting project configuraiton for [$Owner/$ProjectNumber] <<<" | Write-MyDebug -Section "ProjectConfig" -object $ret

    return $ret

} Export-ModuleMember -Function Set-ProjectConfig

function Clear-ProjectConfig {
    [CmdletBinding()]
    param(
        [Parameter()][string]$Owner,
        [Parameter()][string]$ProjectNumber,
        [Parameter()][switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    "[Clear-ProjectConfig] Clearing project configuraiton for $Owner/$ProjectNumber >>>" | Write-MyDebug -Section "ProjectConfig"
    
    $p = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems
    $readme = $p.readme
    
    # Clear the config from the readme
    $newReadMe = clearConfigFromReadme -ReadMe $readme
    
    if([string]::IsNullOrWhiteSpace($newReadMe)){
        "[Clear-ProjectConfig] ERROR: Failed to clear config from readme. New readme is empty or whitespace. Aborting update." | Write-MyDebug -Section "ProjectConfig"
        return $false
    }
    
    # Edit project with new readme
    $ret = Edit-Project -Owner $Owner -ProjectNumber $ProjectNumber -Readme $newReadMe
    
    "[Clear-ProjectConfig] Clearing project configuraiton for $Owner/$ProjectNumber <<<" | Write-MyDebug -Section "ProjectConfig" -object $ret

    return $ret

} Export-ModuleMember -Function Clear-ProjectConfig

function Get-ProjectConfigFromReadme($readme){

    $ret = @{}

    if ([string]::IsNullOrWhiteSpace($readme)) {
        return $ret
    }

    # Parse the readme as XML using the native .NET XmlDocument parser
    try {
        [xml]$doc = "<root>$readme</root>"
    }
    catch {
        "Failed to parse readme as XML. Error: $($_.Exception.Message).`n Readme content: $readme" | Write-MyDebug -Section "Get-ProjectConfig"
        return $ret
    }

    $detailsNodes = $doc.SelectNodes('/root/details')
    foreach ($node in $detailsNodes) {
        $summaryNode = $node.SelectSingleNode('./summary')
        if ($null -eq $summaryNode) {
            "[Get-ProjectConfig] ERROR: Summary section not found. Skipping this node.`n Readme content: $readme" | Write-MyDebug -Section "ProjectConfig"
            continue
        }

        # Check if the summary text matches the expected summary for config
        if ($summaryNode.InnerText.Trim() -ne $SUMMARY_NAME) {
            "ERROR: Details node with summary [$SUMMARY_NAME] not found. [$($summaryNode.InnerText.Trim())] found. Skipping this node.`n Readme content: $readme" | Write-MyDebug -Section "Get-ProjectConfig"
            continue
        }

        # We found the correct <details> node, now extract the JSON config from the <p> section inside it
        $pNode = $node.SelectSingleNode('./p')
        if ($null -eq $pNode) {
            "ERROR: <p> section not found. Skipping this node.`n Readme content: $readme" | Write-MyDebug -Section "Get-ProjectConfig"
            return $ret
        }

        # Get the inner text of the <p> node, which should contain the JSON config
        $jsonConfig = $pNode.InnerText.Trim()
        if ([string]::IsNullOrWhiteSpace($jsonConfig)) {
            "ERROR: Empty <p> section. Skipping this node.`n Readme content: $readme" | Write-MyDebug -Section "Get-ProjectConfig"
            return $ret
        }

        # Parse the JSON config
        try{
            $ret = $jsonConfig | ConvertFrom-Json -AsHashtable
        } catch {
            "ERROR: Failed to parse JSON config. Error: $($_.Exception.Message). Skipping this node.`n Readme content: $readme" | Write-MyDebug -Section "Get-ProjectConfig"
            return $ret
        }
    }

    return $ret
}

# Replace the ProjectHelper_Configuration section in the readme with the new config json
function Merge-ConfigToString {
    [CmdletBinding()]
    param(
        [object]$Config,
        [string]$ReadMe
    )

    # Convert the config hashtable to JSON
    $jsonConfig = $Config | ConvertTo-Json -Depth 10

    # Create the new <details> node with the JSON config
    $newDetailsNode = "<details><summary>$SUMMARY_NAME</summary><p>`n$jsonConfig`n</p></details>"

    # remove detail section is exists to avoid duplication in the readme
    $readme = clearConfigFromReadme -ReadMe $ReadMe

    if([string]::IsNullOrWhiteSpace($readme)){
        $updatedReadme = $newDetailsNode
    } else {
        $updatedReadme = "$readme`n`n$newDetailsNode"
    }

    return $updatedReadme
    
} Export-ModuleMember -Function Merge-ConfigToString

function clearConfigFromReadme {
    [CmdletBinding()]
    param(
        [string]$ReadMe
    )

    # Remove the ProjectHelper_Configuration section from the readme
    $updatedReadme = [regex]::Replace($ReadMe, "<details>\s*<summary>\s*$SUMMARY_NAME\s*</summary>.*?</details>", "", [System.Text.RegularExpressions.RegexOptions]::Singleline)

    return $updatedReadme.Trim()
} Export-ModuleMember -Function Clear-ConfigFromReadme