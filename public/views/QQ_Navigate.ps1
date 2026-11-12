$stacks = @{}

function getStacks($Owner,$ProjectNumber){
    
    $key = "$Owner-$ProjectNumber"
    
    if(-not $stacks.ContainsKey($key)){
        $stacks[$key] = @{
            Backward = [System.Collections.Stack]::new()
            Forward = [System.Collections.Stack]::new()
        }
    }

    return ,$stacks[$key]
}

function Get_StackBackward{
    ($Owner, $ProjectNumber) = Resolve-ProjectParameters
    $stacks = getStacks $Owner $ProjectNumber
    return ,$stacks.Backward
}

function Get_StackForward{
    ($Owner, $ProjectNumber) = Resolve-ProjectParameters
    $stacks = getStacks $Owner $ProjectNumber
    return ,$stacks.Forward
}

function Get-QQ_Stacks {
    [CmdletBinding()]
    [Alias("hhh")]
    param(
        [switch]$Passthru
    )

    ($Owner, $ProjectNumber) = Resolve-ProjectParameters

    # change order to generat the loggica F -> B sequence

    # Order Forward down up - Next is at the bottom
    $forward = (Get_StackForward).ToArray()
    [array]::Reverse($forward)
    $forward | ForEach-Object{
        writeItem $_ "Cyan" $Passthru
        # $i = gpi $_ ; [PsCustomObject]@{stack = "F" ; id= $i.id; Title = $i.Title}
    }

    # ORder backward top down, Next is at the top.
    $backward = (Get_StackBackward).Clone()
    
    # Write the actual 
    $backward.Pop() | ForEach-Object{
        writeItem $_ "Yellow" $Passthru
        # $i = gpi $_ ; [PsCustomObject]@{stack = "Actual" ; id= $i.id; Title = $i.Title}
    }
    
    #Write the remaining backward stack without the top element
    $backward.ToArray() | ForEach-Object{
        writeItem $_ "Green" $Passthru
        # $i = gpi $_ ; [PsCustomObject]@{stack = "B" ; id= $i.id; Title = $i.Title}
    }
    

} Export-ModuleMember -Function Get-QQ_Stacks -alias 'hhh'

function writeItem($id,$color,$passthru=$false){
    $i = gpi $id

    if($passthru){
        return [PsCustomObject]@{color = $color ; id= $i.id; Title = $i.Title}
    } else {
        Write-Host "$($i.id)  ""$($i.Title)""" -ForegroundColor $color
    }
}