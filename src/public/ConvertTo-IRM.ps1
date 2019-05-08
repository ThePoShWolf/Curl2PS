Function ConvertTo-IRM {
    [cmdletbinding()]
    param (
        [curlcommand]$CurlCommand
    )

    $CurlCommand.ToIRM()
}