function Test_ConvertTo_Number_Valid {

    Invoke-PrivateContext {

        # Equal to 10.1
        "10.1", "10,1" | ForEach-Object {
            Assert-AreEqual -Expected 10.1 -Presented $(ConvertTo-Number $_)
        }

        # Equal to 1000.1
        "1,000.1", "1.000,1" | ForEach-Object {
            Assert-AreEqual -Expected 1000.1 -Presented $(ConvertTo-Number $_)
        }
    }
}

function Test_ConvertTo_Number_NotValid{

    Invoke-PrivateContext {

        # Not a number
        "abc", "10..1", "10,1.5", "10,1,5","1.000.1","1,000,1" | ForEach-Object {
            $hasThrow = $false
            try {
                ConvertTo-Number $_ | Out-Null
            } catch {
                $hasThrow = $true
            } finally{
                if(-not $hasThrow){
                    Write-Host "Value '$_' was incorrectly parsed as a number"
                }
            }
            Assert-IsTrue -Condition $hasThrow -Comment "Should throw as the value is not a number"
        }
    }

}