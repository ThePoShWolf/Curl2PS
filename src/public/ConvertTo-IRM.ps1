Function ConvertTo-IRM {
    <#
    .SYNOPSIS
        Converts a CURL command to a Invoke-RestMethod command
    .DESCRIPTION
        
    .EXAMPLE
        
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        v:0.2
    #>
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
    $Null = $CurlString -match 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=\/]{2,256}(\.[a-z]{2,6}\b)|([-a-zA-Z0-9@:%_\+.~#?&\/\/=,]*)'
    $url = $Matches[0]

    $escapedUrl = [regex]::Escape($url)
    $workingStr = $CurlString -replace '^curl\s+','' -replace "['`"]?$escapedUrl['`"]?",''

    If($url -match 'https?:\/\/(?<up>[^@]+)@'){
        $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Matches.up))
        $headers['Authorization'] = "Basic $encodedAuth"
        $url = $url -replace "$($Matches.up)@",''
    }
    # Match the parameter name
    While ($workingStr -match '^\-{1,2}(?<param>[^\s]+)'){
        $parameterName = $Matches.param
        $parameterLength = $Matches[0].Length
        

        # Match parameter value
        if ($workingStr -match '\s\-\S'){
            $index = $workingStr.IndexOf($Matches[0])
        } else {
            $index = $workingStr.Length
        }

        $parameterValue = $workingStr.Substring(0,$index)
        $parameterValue = $parameterValue.Substring($parameterLength).Trim()
        #$parameterValue = $parameterValue -replace "^['`"]",''
        #$parameterValue = $parameterValue -replace "['`"]$",''
        switch ($parameterName){
            {'H','header' -contains $_} {
                $parameterValue = $parameterValue -replace "^['`"]",''
                $parameterValue = $parameterValue -replace "['`"]$",''
                $split = $parameterValue.Split(':')
                $headers[($split[0].Trim())] = ($split[1].Trim())
            }
            {'X','request' -contains $_} {
                $outString += " -Method $($parameterValue.Trim())"
            }
            {'v','verbose' -contains $_} {
                $outString += " -Verbose"
            }
            {'d','data' -contains $_} {
                $outString += " -Body $($parameterValue.Trim())"
            }
            default {
                "unknown: $($parameterValue)"
            }
        }

        $workingStr = $workingStr.Substring($index).Trim()
    }
    $outString += " -Headers ('$($headers | ConvertTo-Json -Compress)' | ConvertFrom-Json)"
    $outString
}