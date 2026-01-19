function Get-Mock_Today{
    $ret = @{
        today = "2025-03-15"
        past = "2024-02-18"
    }

    return $ret
}

function Mock_Today{

    $today = (Get-Mock_Today).today
    MockCallToString -Command "Get-Date -Format yyyy-MM-dd" -OutString $today
}