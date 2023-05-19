Function Get-CurlCommand {
    [OutputType([CurlCommand])]
    param (
        [ValidateScript({ $_.Trim() -match '^curl(?:\.exe)? ' })]
        [string]$CurlString
    )
    [CurlCommand]::new($CurlString.Trim())
}