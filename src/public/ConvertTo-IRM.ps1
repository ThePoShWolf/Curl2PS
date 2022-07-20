Function ConvertTo-IRM {
    [OutputType([System.Collections.Hashtable], ParameterSetName = 'asSplat')]
    [OutputType([System.String], ParameterSetName = 'asString')]
    [cmdletbinding(
        DefaultParameterSetName = 'asSplat'
    )]
    param (
        [Parameter(
            Position = 0
        )]
        [CurlCommand]$CurlCommand,
        [Parameter(
            ParameterSetName = 'asString'
        )]
        [switch]$CommandAsString
    )
    if ($CommandAsString.IsPresent) {
        $CurlCommand.ToIRM()
    } else {
        $CurlCommand.ToIRMSplat()
    }
}