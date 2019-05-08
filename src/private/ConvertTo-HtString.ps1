Function ConvertTo-HtString {
    param (
        [hashtable]$InputObject
    )
    $strKeys = @()
    foreach ($key in $InputObject.Keys){
        $strKeys += "    '$key' = '$($InputObject[$key])'"
    }
    $str = "@{`n" + ($strKeys -join "`n") + "`n}"
    $str
}