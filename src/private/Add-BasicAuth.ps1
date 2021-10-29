Function Add-BasicAuth {
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateScript({$null -ne $_.Value -and $_.Value.GetType() -eq [CurlCommand]},"The type of the parameter 'CurlCommand' must be of type '[ref]CurlCommand'")]
        [ref]
        $CurlCommand,
        [string]
        [Parameter(Mandatory, Position=1, ValidateScript={$Auth -like '*:*'})]
        $Auth)
        $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Auth))
        $urlNoAuth = $CurlCommand.Value.URL.OriginalString -replace "$($Auth)@",''
        $CurlCommand.Value.URL = [System.Uri]::new($urlNoAuth)
        $CurlCommand.Value.Headers['Authorization'] = "Basic $encodedAuth"
}