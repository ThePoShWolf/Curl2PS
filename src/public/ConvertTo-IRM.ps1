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

    # Removes curl from the start
    # Removes the url
    $escapedUrl = [regex]::Escape($url)
    $workingStr = $CurlString -replace '^curl\s+','' -replace "['`"]?$escapedUrl['`"]?",''

    # Match basic auth
    If($url -match 'https?:\/\/(?<up>[^@]+)@'){
        $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Matches.up))
        $headers['Authorization'] = "Basic $encodedAuth"
        $url = $url -replace "$($Matches.up)@",''
    }

    # Add the uri to the output
    $outString += " -Uri '$url'"

    # Match the parameter name
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
                $headers[($split[0].Trim())] = (($split[1..$($split.count)] -join ':').Trim())
            }
            {'X','request' -contains $_} {
                # Request type
                $outString += " -Method $($matches.paramValueQuotes.Trim())"
            }
            {'v','verbose' -contains $_} {
                # Verbosity
                $outString += " -Verbose"
            }
            {'d','data' -contains $_} {
                # Body
                $outString += (" -Body '$($matches.paramValue.Trim())'" -replace '\\"','"')
            }
            default {
                # Unknown
                "unknown: $($matches[0])"
            }
        }

        # Remove the param name and value from the workingStr
        $escapedMatch = [regex]::Escape($Matches[0])
        $workingStr = ($workingStr -replace $escapedMatch,'').Trim()
    }
    # Add headers on the end
    # To output as string, converting them to json and adding ConvertFrom-Json
    $outString += " -Headers ('$($headers | ConvertTo-Json -Compress)' | ConvertFrom-Json)"
    $outString
}