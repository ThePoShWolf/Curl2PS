Function Get-CurlCommand {
    param (
        [ValidateScript({$_.ToLower() -match '^curl '})]
        [string]$CurlString
    )
    [curlcommand]::new($CurlString)
}