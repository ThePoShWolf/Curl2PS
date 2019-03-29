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
    $CurlString -match 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=,]*)' | Out-Null
    $url = $Matches[0]

    ## Most of the blow part is not needed anymore when using Get-URLData
    ## Currently, this is not implemented. It is just so you can see, how this works ;)
    $UrlData = Get-URLData -Url $CurlString # Will automatically discard if 'curl' is in front of the URL

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
Function Get-URLData {
    <#
    .SYNOPSIS
        This function parses a URL and returns an object with all the detailed information of it
    .DESCRIPTION
        Long description
    .EXAMPLE

        Get-UrlData -Url 'https://Google.com/Search'

        #returns the following object

        Name                           Value
        ----                           -----
        FullUrl                        https://Google.com/Search
        BaseUrl                        https://Google.com
        DomainName                     Google.com
        Extension                      .com
        BaseName                       Google
        Path                           /Search
        Protocol                       https
        QueryString
        Fragment


    .INPUTS
        String
    .OUTPUTS
        Object
    .NOTES
        v0.3
        Author: StÃ©phane van Gulick
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Url,
    
        [Switch]
        $IsValidURL
    )
    $Regex = "(?'FullUrl'(?'BaseUrl'(?'Protocol'https?):\/\/(?'DomainName'(?:www\.)?(?'BaseName'[a-zA-Z0-9@:%_\+~#=-]{2,256})(?'Extension'\.[a-zA-Z]{2,6}\b)?)?)(?'Path'[-a-zA-Z0-9@:%_\+.~#&\/\/=,]+)?)(?'QueryString'\?[a-zA-Z0-9@:%_\+.~?&\/\/=]*)?(?'Fragment'#[a-zA-Z0-9@:%_\+.~#&\/\/=]*)?"
    $Null =$Url -match $Regex
    
    If($Matches){
        $Hash = [Ordered]@{}
        $Hash.FullUrl = $Matches.FullUrl
        $Hash.BaseUrl = $Matches.BaseUrl
        $Hash.DomainName = $Matches.DomainName
        $Hash.Extension = $Matches.Extension
        $Hash.BaseName = $Matches.BaseName
        $Hash.Path = $Matches.Path
        $Hash.Protocol = $Matches.Protocol
        $Hash.QueryString = $Matches.QueryString
        $Hash.Fragment = $Matches.Fragment
        Return New-Object psobject -ArgumentList $Hash
        
    }

} 
    
