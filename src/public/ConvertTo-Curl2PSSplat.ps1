Function ConvertTo-Curl2PSSplat {
    [OutputType([hashtable])]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Curl2PSParameterDefinition[]]$Parameters
    )
    $splat = @{}
    foreach ($paramGroup in $parameters | Group-Object ParameterName) {
        if ($paramGroup.Count -gt 1) {
            if ($paramGroup[0].Group[0].Type -eq 'Hashtable') {
                $ht = @{}
                foreach ($pg in $paramGroup.Group) {
                    foreach ($key in $pg.Value.Keys) {
                        $ht[$key] = $pg.Value[$key]
                    }
                }
                try {
                    $convertedHt = Invoke-GetItemInHashtable $ht
                } catch {
                    $convertedHt = $ht
                }
                $splat[$paramGroup.Name] = $convertedHt
            } else {
                Write-Warning "Multiple values for parameter $($paramGroup.Name) of type '$($paramGroup.Group[0].Type)' are not supported."
            }
        } else {
            $splat[$paramGroup.Name] = $paramGroup.Group[0].Value
        }
    }
    $splat
}