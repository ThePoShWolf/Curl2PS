Function Get-CurlCommand {
    [OutputType([CurlCommand])]
    param (
        [ValidateScript({ $_.ToLowerInvariant().Trim() -match '^curl ' })]
        [string]$CurlString
    )
    [CurlCommand]::new($CurlString.Trim())
}