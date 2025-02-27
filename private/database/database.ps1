# # Database driver to store and cacche project content and schema


# $script:PROJECT_DATABASE_LIST = $null

# function Initialize-DatabaseRoot{
#     [CmdletBinding()]
#     param()
    
#         $script:PROJECT_DATABASE_LIST = @{}

# } Export-ModuleMember -Function Initialize-DatabaseRoot

# function Get-DatabaseRoot{
#     [CmdletBinding()]
#     param()

#     if($null -eq $script:PROJECT_DATABASE_LIST){
#         Initialize-DatabaseRoot
#     }

#     return $script:PROJECT_DATABASE_LIST
# }

# function Get-Database{
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)][string]$Owner,
#         [Parameter(Position = 1)][int]$ProjectNumber
#     )

#     $root = Get-DatabaseRoot

#     $ret = $root."$owner/$projectnumber"

#     return $ret
# }

# function Save-Database{
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)][string]$Owner,
#         [Parameter(Position = 1)][int]$ProjectNumber,
#         [Parameter(Position = 2)][Object]$Database
#     )

#     $root = Get-DatabaseRoot

#     $root."$owner/$projectnumber" = $Database
# }