
$SUMMARY_NAME = "ProjectHelper_Configuration"

function Get-ProjectConfig {
    [CmdletBinding()]
    param(
        [string]$Owner,
        [string]$ProjectNumber,
        [switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    "Getting project configuraiton for $Owner/$ProjectNumber and Force=$Force >>>" | Write-MyDebug -Section "Get-ProjectConfig"

    $p = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems

    $readme = $p.readme

    # Extract config json from readme
    $config = Get-ProjectConfigFromReadme -Readme $readme

    "Project configuration found." | Write-MyDebug -Section "Get-ProjectConfig" -Object $config
   
    return $config
} Export-ModuleMember -Function Get-ProjectConfig

function Set-ProjectConfig {
    [CmdletBinding()]
    param(
        [string]$Owner,
        [string]$ProjectNumber,
        [hashtable]$Config,
        [switch]$Force
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters -Owner $Owner -ProjectNumber $ProjectNumber

    "Setting project configuraiton for $Owner/$ProjectNumber >>>" | Write-MyDebug -Section "Set-ProjectConfig"

    $p = Get-Project -Owner $Owner -ProjectNumber $ProjectNumber -Force:$Force -SkipItems

    $readme = $p.readme

    # Extract config json from readme
    $currentConfig = Get-ProjectConfigFromReadme -Readme $readme

    # Merge current config with new config
    foreach($key in $Config.Keys){
        $currentConfig.$key = $Config.$key
    }

    # Update the readme with the new config json
    $newReadMe = Merge-ConfigToString -Config $currentConfig -ReadMe $readme

    if([string]::IsNullOrWhiteSpace($newReadMe)){
        "ERROR: Failed to merge config to readme. New readme is empty or whitespace. Aborting update." | Write-MyDebug -Section "Set-ProjectConfig"
        return $false
    }

    # Edit project with new readme
    $ret = Edit-Project -Owner $Owner -ProjectNumber $ProjectNumber -Readme $newReadMe

    return $ret

} Export-ModuleMember -Function Set-ProjectConfig

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
            "ERROR: Summary section not found. Skipping this node.`n Readme content: $readme" | Write-MyDebug -Section "Get-ProjectConfig"
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
            $ret = $jsonConfig | ConvertFrom-Json
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
    $readme = [regex]::Replace($ReadMe, "<details>\s*<summary>\s*$SUMMARY_NAME\s*</summary>.*?</details>", "", [System.Text.RegularExpressions.RegexOptions]::Singleline)

    $readme = $readme.Trim()

    if([string]::IsNullOrWhiteSpace($readme)){
        $updatedReadme = $newDetailsNode
    } else {
        $updatedReadme = "$readme`n`n$newDetailsNode"
    }

    return $updatedReadme
    
} Export-ModuleMember -Function Merge-ConfigToString