Function Get-CurlCommand {
    param (
        [ValidateScript({$_.ToLowerInvariant().Trim() -match '^curl '})]
        [string]$CurlString
    )
    [CurlCommand]::new($CurlString.Trim())
}