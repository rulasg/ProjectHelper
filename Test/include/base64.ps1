function ConvertTo-Base64 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline, Position=0)][string[]]$Text
    )

    process{
        # Encode the string to base64
        $ret = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
        return $ret
    }
}

function ConvertFrom-Base64 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline, Position=0)][string[]]$Text
    )

    process{
        $ret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Text))
        return $ret
    }
}