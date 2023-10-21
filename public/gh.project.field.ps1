function Get-GhPField{
    [CmdletBinding()]   
    param(
        [Parameter()][string]$ProjectNumber,
        [Parameter()][string]$Owner
    )

# > gh project field-list 11 --owner rulasg

# NAME                  DATA TYPE                   ID
# Title                 ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgMy4G4
# Assignees             ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgMy4G8
# Status                ProjectV2SingleSelectField  PVTSSF_lAHOAGkMOM4AUB10zgMy4HA
# Labels                ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgMy4HE
# Linked pull requests  ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgMy4HI
# Reviewers             ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgMy4HQ
# Repository            ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgMy4HU
# Milestone             ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgMy4HY
# comment               ProjectV2Field              PVTF_lAHOAGkMOM4AUB10zgM0BvM

    gh project field-list $ProjectNumber --owner $Owner

}
