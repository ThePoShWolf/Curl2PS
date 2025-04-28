Function ConvertTo-IRM {
    [OutputType([hashtable], ParameterSetName = 'splat')]
    [OutputType([string], ParameterSetName = 'string')]
    [cmdletbinding(
        DefaultParameterSetName = 'splat'
    )]
    param (
        [Parameter(
            Position = 0
        )]
        [string]$CurlCommand,
        [Parameter(
            ParameterSetName = 'asString'
        )]
        [switch]$CommandAsString,
        [switch]$CompressJSON
    )

    if ($CompressJSON.IsPresent) {
        Write-Warning 'The CompressJSON switch is no longer valid.'
    }

    if ($CommandAsString.IsPresent) {
        Invoke-Curl2PS -CurlString $CurlCommand -AsString
    } else {
        Invoke-Curl2PS -CurlString $CurlCommand
    }
}