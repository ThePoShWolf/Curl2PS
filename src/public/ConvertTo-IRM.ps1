Function ConvertTo-IRM {
    param (
        [ValidateScript({$_.ToLower() -match '^curl '})]
        [string]$CurlString
    )
    # variables
    $headers = @{}
    $outString = "Invoke-RestMethod"

    # Match the url
    # regex from: https://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
    # I added a comma in the case of multiple parameter values in uri.
    $CurlString -match 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=,]*)' | Out-Null
    $url = $Matches[0]

    $escapedUrl = [regex]::Escape($url)
    $workingStr = $CurlString -replace '^curl\s+','' -replace "['`"]?$escapedUrl['`"]?",''

    If($url -match 'https?:\/\/(?<up>[^@]+)@'){
        $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Matches.up))
        $headers['Authorization'] = "Basic $encodedAuth"
        $url = $url -replace "$($Matches.up)@",''
    }

    $outString += " -Uri '$url'"

    # Match the parameter name
    While ($workingStr -match '^(?<param>\-{1,2}[^\s]+)'){
        $parameterName = $Matches.param
        #$parameterLength = $Matches[0].Length
        
        # Match parameter value
        # Don't match quotes except for excaped quotes: \"
        $escapedParamName = [regex]::Escape($parameterName)
        $workingStr -match "$escapedParamName (?<paramValueQuotes>`'(?<paramValue>[^']+)`'|`"(?<paramValue>((\\`")|[^`"])+)`"|(?<paramValue>[^\s]+))" | Out-Null

        #$parameterValue = $workingStr.Substring(0,$index)
        #$parameterValue = $parameterValue.Substring($parameterLength).Trim()
        #$parameterValue = $parameterValue -replace "^['`"]",''
        #$parameterValue = $parameterValue -replace "['`"]$",''
        switch ($parameterName.Trim('-')){
            {'H','header' -contains $_} {
                #$parameterValue = $parameterValue -replace "^['`"]",''
                #$parameterValue = $parameterValue -replace "['`"]$",''
                #$split = $parameterValue.Split(':')
                $split = $Matches.paramValue.Split(':')
                $headers[($split[0].Trim())] = ($split[1].Trim())
            }
            {'X','request' -contains $_} {
                $outString += " -Method $($matches.paramValueQuotes.Trim())"
            }
            {'v','verbose' -contains $_} {
                $outString += " -Verbose"
            }
            {'d','data' -contains $_} {
                $outString += (" -Body '$($matches.paramValue.Trim())'" -replace '\\"','"')
            }
            default {
                "unknown: $($matches[0])"
            }
        }

        #$workingStr = $workingStr.Substring($index).Trim()
        $escapedMatch = [regex]::Escape($Matches[0])
        $workingStr = ($workingStr -replace $escapedMatch,'').Trim()
    }
    $outString += " -Headers ('$($headers | ConvertTo-Json -Compress)' | ConvertFrom-Json)"
    $outString
}