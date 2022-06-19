Function ConvertTo-IRM {
    [cmdletbinding()]
    param (
        [CurlCommand]$CurlCommand,
        [switch]$CommandAsString
    )
    if ($CommandAsString.IsPresent) {
        $CurlCommand.ToIRM()
    } else {
        $CurlCommand.ToIRMSplat()
    }
}