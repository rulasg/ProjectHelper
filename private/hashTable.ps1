<#
.SYNOPSIS
    Creates a new hashtable object.
.DESCRIPTION
    This function creates and returns a new hashtable object.
    We need this function to avoid creating hashtables not case sensitive with @{}
    Projects items and fields Ids are case sensitive and and we may have colisions.
#>
Function New-HashTable(){
    # Return a case-sensitive hashtable
    $ret = New-Object System.Collections.Hashtable
    return $ret
}