
$moduleName = Get-ModuleName

function Register-QQ_Commands{

    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Get_G"              -Alias "g"  -Description "Get the current item id"                     -ScriptBlock { $i = Get-QQ_ItemId ; return $i}
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Get_O"              -Alias "p"  -Description "Get the previouse item id"                   -ScriptBlock { $i = Get-QQ_Previouse_ItemId ; return $i}
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Help"               -Alias "hh" -Description "Show help commands"                          -ScriptBlock { W '$script:Help_Commands' ; $script:Help_Commands }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Get_B"              -Alias "b"  -Description "Get the previouse item id"                   -ScriptBlock { $i = Get-QQ_Previouse_ItemId ;  W "Show-ProjectItem $i" ; $i | Show-ProjectItem }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Get_GG"             -Alias "gg" -Description "Get the project item for the current item id" -ScriptBlock { $i = g ; W "Get-ProjectItem $i" ; $i | Get-ProjectItem }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Get_Title_T"        -Alias "t"  -Description "Get the title of the current item"            -ScriptBlock { $i = g ; W "Get Title $i" ; $i | gpi | Select-Object id,title }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Open_O"             -Alias "o"  -Description "Open the current item in a new window"        -ScriptBlock { $i = g ; W "Open-ProjectItem $i" ; $i | Open-ProjectItem }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Remove_RE"          -Alias "re" -Description "Remove the current item from projet"          -ScriptBlock { $i = g ; W "Remove-ProjectItem $i" ; $i | Remove-ProjectItem }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_GetUrl_UU"          -Alias "uu"  -Description "Get the URL of the current item"              -ScriptBlock { $i = g ; W "Get-ProjectItemUrl $i -SetCliboard" ; $i | Get-ProjectItemUrl -SetClipboard}
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Update_U"           -Alias "u"  -Description "Update project item"                          -ScriptBlock { $i = g ; W "Update-ProjectItem $i" ; $i | Update-ProjectItem ; g | Show-ProjectItem }
    
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Commit_C"           -Alias "c"  -Description "Commit the current item"                      -ScriptBlock { W "Sync-ProjectItemStaged" ; Sync-ProjectItemStaged }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Commit_Y"           -Alias "y"  -Description "Sync the current item"                        -ScriptBlock { W "Sync-ProjectItemStaged" ; Sync-ProjectItemStaged }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Commit_YY"          -Alias "yy" -Description "Sync Async the current item"                  -ScriptBlock { W "Sync-ProjectItemStagedAsync" ; Sync-ProjectItemStagedAsync }
    
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Show_V"             -Alias "v"  -Description "Show the current item in the console"         -ScriptBlock { $i = g ; W "Show-ProjectItem $i" ; $i | Show-ProjectItem }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_ShowDetails_D"      -Alias "d"  -Description "Show the details of the current item"          -ScriptBlock { $i = g ; W "Show-ProjectItem $i -AllComments " ; $i | Show-ProjectItem -AllComments }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_ShowMini_M"         -Alias "m"  -Description "Show a minimal view of the current item"      -ScriptBlock { $i = g ; W "Show-ProjectItem $i -Minimal " ; $i | Show-ProjectItem -Minimal }

    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_Open_IM_I"          -Alias "i"  -Description "Open the IM for the current item"             -ScriptBlock { $i = g ; W "Open-SalesProjectItemIM $i" ; $i | Open-SalesProjectItemIM }
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_Open_Notes_N"       -Alias "n"  -Description "Open the notes for the current item"          -ScriptBlock { $i = g ; W "Open-SalesProjectItemNotesLink $i" ; $i | Open-SalesProjectItemNotesLink }
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_Open_SupportLink_S" -Alias "s"  -Description "Open support link for the current item"       -ScriptBlock { $i = g ; W "Open-SalesProjectItemSupportLink $i" ; $i | Open-SalesProjectItemSupportLink }
    
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_Ready_QR"           -Alias "qr"  -Description "Set item as ready "                          -ScriptBlock { $i = g ; W "e -Ready $i" ; $i | e -Ready }
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_FollowUp_QF"        -Alias "qf"  -Description "Set item for follow-up "                      -ScriptBlock { $i = g ; W "e -FollowUp $i" ; $i | e -FollowUp }
    
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_NextTodo_X"        -Alias "x"  -Description "Show next item"                               -ScriptBlock {param([parameter(Position=0)]$arg1) W "Show-SalesTodoNext" ; Show-SalesTodoNext $arg1}
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_NextCleint_XC"      -Alias "xc"  -Description "Show next item for client"                  -ScriptBlock { W "Show-SalesTodoNext -Topic Client" ; Show-SalesTodoNext -Topic Client }
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_NextNotifi_XS"      -Alias "xs"  -Description "Show next notification item"                -ScriptBlock { W "Show-SalesNotificationsNext" ; Show-SalesNotificationsNext }
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_NextInbox_XX"       -Alias "xx"  -Description "Show next inbox item"                       -ScriptBlock { W "Show-SalesInboxNext " ; Show-SalesInboxNext }
    
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_ShowCommit_SC"      -Alias "sc"  -Description "Show the staged items"                      -ScriptBlock { $i = g ; W "Show-ProjectItemStaged" ; $i | Show-ProjectItemStaged }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_ResetCommit_RC"     -Alias "rc"  -Description "Reset the staged items"                      -ScriptBlock { $i = g ; W "Reset-ProjectItemStaged" ; $i | Reset-ProjectItemStaged }
    
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_ShowStaged_SS"      -Alias "ss"  -Description "Show staged items"                          -ScriptBlock { W "Show-ProjectItemStaged" ; Show-ProjectItemStaged }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_ShowStaged_Detail_SSS"      -Alias "sss"  -Description "Show staged items details"         -ScriptBlock { W "Show-ProjectItemStaged | Show-ProjectItemStaged " ; Show-ProjectItemStaged | Show-ProjectItemStaged }
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_ResetStaged_RS"      -Alias "rs"  -Description "Reset staged items"                        -ScriptBlock { W "Reset-ProjectItemStaged" ; Reset-ProjectItemStaged }
    
    # New-QQ_Function -Module $modulename -Name "Invoke-QQ_Reset_Notification_RRN" -Alias "rrn" -Description "Resolve notifications for the current item"     -ScriptBlock { $i = g ; W "g | get-projectItemUrl | Get-NotificationByUrl | Read-Notification" ; $i | Get-ProjectItemUrl | Get-NotificationByUrl | Read-Notification }
    
    # #open parent
    New-QQ_Function -Module $modulename -Name "Invoke-QQ_Open_Parent_PP"      -Alias "pp"  -Description "Open the parent item in a new window" -ScriptBlock { $i = g ; W "g | gpi | Select-Object -ExpandProperty parent | Select-Object -ExpandProperty url | Open-MyUrl" ; $i | gpi | Select-Object -ExpandProperty  parent | Select-Object -ExpandProperty url | Open-MyUrl }
}