function Test_UpdateProjectItemStatusOnDueDate {

    Reset-InvokeCommandMock
    Mock_DatabaseRoot

    # Mock calling Toda
    MockCallToString -Command "Get-Date -Format yyyy-MM-dd" -OutString "2025-03-15"

    $mp = Get-Mock_Project_625 ; $owner = $mp.owner ; $projectNumber = $mp.number
    MockCall_GetProject -MockProject $mp -Cache

    $p = $mp.updateStatusOnDueDate
    $statusFieldId = $p.fields.status.id
    $otherDone = $p.statusDoneOther

    # Act and Assert
    function Assert-DueDateStaged{
        param(
            [Parameter()][object]$Expected,
            [Parameter(Position=1)][bool]$AnyStatus,
            [Parameter(Position=2)][bool]$IncludeDoneItems,
            [Parameter(Position=3)][string]$StatusDone
        )

        Reset-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber
        $params = @{
            Owner            = $owner
            ProjectNumber    = $projectNumber
            StatusFieldName  = $p.fields.status.name
            DateFieldName    = $p.fields.dueDate.name
            StatusAction     = $p.statusAction
            StatusPlanned    = $p.statusPlanned
            IncludeDoneItems = $IncludeDoneItems
            StatusDone       = $StatusDone
            AnyStatus        = $AnyStatus
        }

        # Act
        $result = Update-ProjectItemsStatusOnDueDate @params

        # Result is null
        Assert-IsNull -Object $result -Comment "Result is null"

        # Assert
        $staged = Get-ProjectItemStaged -Owner $owner -ProjectNumber $projectNumber

        # Items edited to ActionRequired or Planned
        $total = $Expected.Count
        Assert-AreEqual -Expected $total -Presented $staged.Count
        foreach($id in $Expected.Keys){
            foreach($field in $Expected.$id.Keys){
                Assert-AreEqual -Expected $Expected.$id.$field -Presented $staged.$id.$field.Value -Comment "Item $id Field $field"
            }
        }
    }

    # Assert of the combination of the three parameters

    #                    AnyStatus | IncludeDoneItems | DoneOther  | Expected
    Assert-DueDateStaged   $true         $true           ""          -Expected ($p.staged + $p.anyStatus                      + $p.includeDone  )
    Assert-DueDateStaged   $false        $true           ""          -Expected ($p.staged                                     + $p.includeDone  )
    Assert-DueDateStaged   $true         $false          ""          -Expected ($p.staged + $p.anyStatus                                        )
    Assert-DueDateStaged   $false        $false          ""          -Expected ($p.staged                                                       )
    Assert-DueDateStaged   $true         $true          $otherDone   -Expected ($p.staged + $p.anyStatus_and_includeDoneOther + $p.includeDone  )
    Assert-DueDateStaged   $false        $true          $otherDone   -Expected ($p.staged               + $p.includeDoneOther + $p.includeDone  )
    Assert-DueDateStaged   $true         $false         $otherDone   -Expected ($p.staged + $p.anyStatus_and_includeDoneOther                   )
    Assert-DueDateStaged   $false        $false         $otherDone   -Expected ($p.staged               + $p.includeDoneOther                   )

}




