Function Invoke-GetItemInHashtable {
    param (
        [Hashtable]$ht
    )
    # create a new hashtable to store the resolved values
    $newHt = @{}
    foreach ($key in $ht.Keys) {
        $value = $ht[$key]
        if ($value -is [Hashtable]) {
            # recursively process nested hashtables and add the result to the new hashtable
            $newHt[$key] = Invoke-GetItemInHashtable -ht $value
        } elseif ($value -is [string] -and $value.StartsWith('Get-Item ')) {
            # curl uses the @ symbol in -F to denote files to send. Invoke-RestMethod
            # then expects the FileInfo object (Get-Item) so we need to execute it.
            $scriptBlock = [scriptblock]::Create($value)
            $newHt[$key] = & $scriptBlock
        } else {
            # copy values as-is
            $newHt[$key] = $value
        }
    }
    return $newHt  # Return the new hashtable
}