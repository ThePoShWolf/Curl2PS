Function ConvertTo-IRM {
    [cmdletbinding()]
    param (
        [CurlCommand]$CurlCommand,
        [switch]$GetParamsAsString
    )
    if($CommandAsString.IsPresent){
        $CurlCommand.ToIRM()
    } else {
        $CurlCommand.ToIRMSplat()
    }
}