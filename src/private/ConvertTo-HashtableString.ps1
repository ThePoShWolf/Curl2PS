Function ConvertTo-HashtableString {
    param (
        [Hashtable]$InputObject
    )
    $strKeys = @()
    foreach ($key in $InputObject.Keys | Sort-Object) {
        $strKeys += "    '$key' = '$($InputObject[$key])'"
    }
    $str = "@{`n" + ($strKeys -join "`n") + "`n}"
    $str
}