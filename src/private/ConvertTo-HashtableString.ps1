Function ConvertTo-HashtableString {
    param (
        [Hashtable]$InputObject,
        [int]$Depth = 0
    )
    $strKeys = @()
    $indent = "    " * $Depth  # Indentation based on depth
    foreach ($key in $InputObject.Keys | Sort-Object) {
        $value = $InputObject[$key]
        if ($value -is [Hashtable]) {
            # recursively process nested hashtable
            $nestedHashtableString = ConvertTo-HashtableString -InputObject $value -Depth ($Depth + 1)
            $strKeys += "$indent    '$key' = $nestedHashtableString"
        } else {
            # depth based nesting
            $strKeys += "$indent    '$key' = '$value'"
        }
    }
    $str = "$indent@{`n" + ($strKeys -join "`n") + "`n$indent}"
    $str
}