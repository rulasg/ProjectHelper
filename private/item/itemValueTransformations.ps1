function Convertto-ItemTransformedValue{
    param(
        [Parameter(Mandatory=$true)][hashtable]$Item,
        [Parameter()][string]$Value
    )

    # Check if the Value contains any {{tag}} patterns
    if ($Value -match '\{\{[^}]+\}\}') {

        # Find all {{tag}} patterns in the value
        $m = [regex]::Matches($Value, '\{\{([^}]+)\}\}')

        $transformedValue = $Value

        foreach ($match in $m) {
            $fullTag = $match.Value  # The full {{tag}} including braces
            $fieldName = $match.Groups[1].Value  # Just the tag name without braces

            # Check if the item has this field
            if (! [string]::IsNullOrEmpty($Item.$fieldName)) {
                $fieldValue = $Item.$fieldName
                # Replace the {{tag}} with the actual field value
                $transformedValue = $transformedValue -replace [regex]::Escape($fullTag), $fieldValue
            }
            else {
                # Field not found - could either leave as is or replace with empty string
                # Leaving as is for now to make it obvious when a field doesn't exist
                Write-Warning "Field '$fieldName' not found in item. Tag '$fullTag' will remain unchanged."
            }
        }

        return $transformedValue
    }

    # No {{tag}} patterns found, return original value
    return $Value
}