Function ConvertTo-IRM {
    [OutputType([System.Collections.Hashtable], ParameterSetName = 'asSplat')]
    [OutputType([System.String], ParameterSetName = 'asString')]
    [cmdletbinding(
        DefaultParameterSetName = 'asSplat'
    )]
    param (
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