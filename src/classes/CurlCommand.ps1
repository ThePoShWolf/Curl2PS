Class CurlCommand {
    [string]$RawCommand
    [string]$Body
    [URL]$URL
    [string]$Method
    [hashtable]$Headers = @{}
    [bool]$Verbose = $false

    CurlCommand(
        [string]$curlString
    ){
        $this.RawCommand = $curlString
        $tmpurl = [url]::new($curlString)
        if ($tmpurl){
            $this.URL = $tmpurl
        } else {
            # No URL present, error
        }
        if ($tmpurl.FullUrl -match 'https?:\/\/(?<up>[^@]+)@'){
            $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Matches.up))
            $this.Headers['Authorization'] = "Basic $encodedAuth"
        }

        # Remove url from string
        $escapedUrl = [regex]::Escape($tmpurl)
        $workingStr = $CurlString -replace '^curl\s+','' -replace "['`"]?$escapedUrl['`"]?",''

        # Find all parameters
        While ($workingStr -match '^(?<param>\-{1,2}[^\s]+)'){
            $parameterName = $Matches.param
            
            # Match parameter value
            # Don't match quotes except for excaped quotes: \"
            $escapedParamName = [regex]::Escape($parameterName)
            $workingStr -match "$escapedParamName (?<paramValueQuotes>`'(?<paramValue>[^']+)`'|`"(?<paramValue>((\\`")|[^`"])+)`"|(?<paramValue>[^\s]+))" | Out-Null
    
            # Do things based on what parameter it is
            switch ($parameterName.Trim('-')){
                {'H','header' -contains $_} {
                    # Headers
                    $split = ($Matches.paramValue.Split(':') -replace '\\"','"')
                    $this.headers[($split[0].Trim())] = (($split[1..$($split.count)] -join ':').Trim())
                }
                {'X','request' -contains $_} {
                    # Request type
                    $this.Method = $matches.paramValue.Trim()
                }
                {'v','verbose' -contains $_} {
                    # Verbosity
                    $this.Verbose = $true
                }
                {'d','data' -contains $_} {
                    # Body
                    $this.body = $matches.paramValue.Trim() -replace '\\"','"'
                }
                default {
                    # Unknown
                    Write-Verbose "unknown: $($matches[0])"
                }
            }
    
            # Remove the param name and value from the workingStr
            $escapedMatch = [regex]::Escape($Matches[0])
            $workingStr = ($workingStr -replace $escapedMatch,'').Trim()
        }
    }

    [string] ToString(){
        return $this.RawCommand
    }

    [string] ToIRM(){
        $outString = 'Invoke-RestMethod'
        $outString += " -Uri $($this.URL.ToString())"
        $outString += " -Method $($this.Method)"
        if ($this.Body.Length -gt 0){
            $outString += " -Body '$($this.Body)'"
        }
        if ($this.Headers.Keys){
            $outString += " -Headers ('$($this.Headers | ConvertTo-Json -Compress)' | ConvertFrom-Json)"
        }
        return $outString
    }
}


#$curlString = 'curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates'