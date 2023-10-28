function New-Issue{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("nghi")]
    param(
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Title,
        [Parameter()][string]$Body
    )

    begin{}

    process{

        # Get default values from Environment
        $Repo = Resolve-EnvironmentRepo -Repo $Repo ; if(!$Repo){return $null}

        # Build expression
        $command = Build-Command -CommandKey Issue_Create -Repo $Repo -Title $Title -Body $Body

        # Invoke Expresion
        if ($PSCmdlet.ShouldProcess("GitHub cli", $command)) {
            $result = Invoke-GhExpression -Command $command
        } else {
            # For Testing
            $command | Write-Information
            $result = 'https://githubInstance.com/someOwner/someRepo/issues/6'
        }

        # Check if its a url
        # $success = Test-NewIssueResult -Result $result -Repo $Repo

        # Check that result is a url
        [Uri]$uri = $null
        $success = ([System.Uri]::TryCreate($result, [System.UriKind]::Absolute, [ref]$uri)) 

        # Error checking
        if(!$success){
            "Error [{0}] calling gh expression [{1}]" -f $result, $command | Write-Error
            return $null
        }

        # Return issue URL
        return $result
    }
} Export-ModuleMember -Function New-Issue -Alias nghi

# function Test-NewIssueResult{
#     [CmdletBinding()]
#     param(
#         [Parameter(Mandatory)][string]$Result,
#         [Parameter(Mandatory)][string]$Repo
#     )

#     begin{}
    
#     process{
#         try{
#             $processing = $result

#             # Split repo
#             $repoSplit = $repo -split "/"
#             $repoOwner = $repoSplit[0]
#             $repoName = $repoSplit[1]

#             # Remove the numbrer
#             $processing = $processing | Split-Path -parent 

#             #Isse
#             ($processing | Split-Path -leaf) -eq "issues" | Assert -Message "Expected 'issues' in path: $processing"

#             $processing = $processing | Split-Path -parent 
            
#             # Repo Name
#             ($processing | Split-Path -leaf) -eq $repoName | Assert -Message "Expected '$repoName' in path: $processing"
            
#             $processing = $processing | Split-Path -parent 

#             #Repo Owner
#             ($processing | Split-Path -leaf) -eq $repoOwner | Assert -Message "Expected '$repoOwner' in path: $processing"

#         } catch {
#             "Error: {0}" -f $_.Exception.Message | Write-Error
#             return $false
#         }

#         return $true
#     }
# }

function Assert{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][bool]$condition,
        [Parameter()][string]$Message
    )

    process{
        if(!$condition){
            # $Message | Write-Error
            throw $Message
        }
    }
}

function Get-Issues{
    [CmdletBinding()]
    [Alias("gghi")]
    param(
        [Parameter()][string]$Repo
    )

    process {
        # Environment
        $Repo = Resolve-EnvironmentRepo -Repo $Repo ; if(!$Repo){return $null}

        $command = Build-Command -CommandKey Issue_List -Repo $Repo

        # Invoke Expresion
        $result = Invoke-GhExpressionToJson -Command $command

        # Return issues
        return $result
    }
} Export-ModuleMember -Function Get-Issues -Alias gghi