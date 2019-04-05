Function ConvertTo-IRM {
    param (
        [curlcommand]$CurlCommand
    )

    $CurlCommand.ToIRM()
}