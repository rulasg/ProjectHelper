function Convert-NodeItemToHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)][object]$NodeItem
    )

    process {
        "Processing Item $($NodeItem.id) - $($NodeItem.content.title)" | Write-Verbose

        $item = New-Object System.Collections.Hashtable
        $item.id = $NodeItem.id
        $item.databaseId = $NodeItem.fullDatabaseId

        # Project
        $item.projectId = $NodeItem.project.id
        $item.projectUrl = $NodeItem.project.url

        # Content
        $item.type = $NodeItem.content.__typename
        $item.body = $NodeItem.content.body
        $item.contentId = $NodeItem.content.id
        # Title is stored in two places. in the content and as a field.
        # We will use the field value
        $item.number = $NodeItem.content.number
        $item.state = $NodeItem.content.state
        $item.urlContent = $NodeItem.content.url
        $item.createdAt = GetDateTime -DateTimeString $NodeItem.content.createdAt
        $item.updatedAt = GetDateTime -DateTimeString $NodeItem.content.updatedAt
        
        # Url
        $item.urlPanel = Build-ItemPanelUrl -Item $item
        $item.url = [string]::IsNullOrWhiteSpace($item.urlContent) ? $item.urlPanel : $item.urlContent

        #Fields
        foreach ($nodefield in $NodeItem.fieldValues.nodes) {
            "      Processing $($nodefield.field.name)" | Write-Verbose

            switch ($nodefield.__typename) {
                "ProjectV2ItemFieldTextValue" {
                    $value = $nodefield.text
                }
                "ProjectV2ItemFieldSingleSelectValue" {
                    $value = $nodefield.name
                }
                "ProjectV2ItemFieldNumberValue" {
                    # $value = $nodefield.number
                    $value = ConvertFrom-FieldValue -Field $nodefield.field -Value $nodefield.number
                }
                "ProjectV2ItemFieldDateValue" {
                    $value = $nodefield.date
                }
                "ProjectV2ItemFieldUserValue" {
                    $value = GetUsers -FieldNode $nodefield
                }
                "ProjectV2ItemFieldRepositoryValue" {
                    $value = $nodefield.repository.url
                }
                "ProjectV2ItemFieldLabelValue" {
                    $value = GetLabels -FieldNode $nodefield
                }
                "ProjectV2ItemFieldMilestoneValue" {
                    $value = $nodefield.milestone.title
                }
                "ProjectV2ItemFieldPullRequestValue" {
                    $value = GetPullRequests -FieldNode $nodefield
                }
                Default {
                    $value = $nodefield.text
                }
            }
            $item.$($nodefield.field.name) = $value
        }

        return $item
    }
}

function Build-ItemPanelUrl{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 1)][object]$Item
    )
    
    $baseUrl = $item.projectUrl
    $uriBuilder = [System.UriBuilder]::new($baseUrl)
    $uriBuilder.Path += "/views/1"

    # Remove the port to avoid :443 in HTTPS URLs
    $uriBuilder.Port = -1

    # Add query parameters
    $query = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
    $query.Add("pane", "issue")
    $query.Add("itemId", $Item.databaseId)

    $uriBuilder.Query = $query.ToString()

    # Get the final URL
    $finalUrl = $uriBuilder.ToString()
    
    return $finalUrl
} 