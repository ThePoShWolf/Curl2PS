Function ConvertTo-IRM {
    [cmdletbinding()]
    param (
        [curlcommand]$CurlCommand,
        [switch]$String
    )
    if($String.IsPresent){
        $CurlCommand.ToIRM()
    } else {
        $CurlCommand.ToIRMSplat()
    }
}