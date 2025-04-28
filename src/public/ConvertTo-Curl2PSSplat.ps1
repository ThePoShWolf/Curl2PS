Function ConvertTo-Curl2PSSplat {
    [OutputType([hashtable])]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Curl2PSParameterDefinition]$Parameter
    )
    Begin {
        $splat = @{}
    }
    Process {
        if ($Parameter.Type -eq 'Hashtable') {
            $ht = @{}
            if ($splat.Keys -contains $Parameter.ParameterName) {
                foreach ($key in $splat[$Parameter.ParameterName].Keys) {
                    $ht[$key] = $splat[$Parameter.ParameterName]
                }
            }
            foreach ($key in $Parameter.Value.Keys) {
                $ht[$key] = $Parameter.Value[$key]
            }
            try {
                $convertedHt = Invoke-GetItemInHashtable $ht
            } catch {
                $convertedHt = $ht
            }
            $splat[$ParameterName] = $convertedHt
        } else {
            $splat[$Parameter.ParameterName] = $Parameter.Value
        }
    }
    End {
        $splat
    }
}