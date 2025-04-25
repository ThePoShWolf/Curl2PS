Function Invoke-Curl2PS {
    [OutputType([hashtable], ParameterSetName = 'splat')]
    [OutputType([string], ParameterSetName = 'string')]
    [OutputType([Curl2PSParameterDefinition[]], ParameterSetName = 'raw')]
    [cmdletbinding(
        DefaultParameterSetName = 'splat'
    )]
    param (
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]$CurlString,
        [Parameter(
            ParameterSetName = 'string'
        )]
        [switch]$AsString,
        [Parameter(
            ParameterSetName = 'raw'
        )]
        [switch]$Raw
    )
    if ($CurlString -match "\n") {
        $arr = $CurlString -split "\n"
        $CurlString = ($arr | ForEach-Object { $_.TrimEnd('\').Trim() }) -join ' '
    }

    $splitParams = Invoke-Command -ScriptBlock ([scriptblock]::Create("parse $CurlString"))
    if ($splitParams[0] -notin 'curl', 'curl.exe') {
        Throw "`$CurlString does not start with 'curl' or 'curl.exe', which is necessary for correct parsing."
    }
    $parameters = for ($x = 1; $x -lt $splitParams.Count; $x++) {
        # If this item is a parameter name, use it
        # The next item must be the parameter value
        # Unless the current item is a switch param
        # If not, increment $x so we skip the next one
        if ($splitParams[$x] -like '-*') {
            [string[]]$paramNames = $splitParams[$x].TrimStart('-')
            if ($splitParams[$x] -match '^-[a-zA-Z]+') {
                # multiple single char flags
                [string[]]$paramNames = $paramNames[0][0..$paramNames[0].Length]
            }
            # grab the value
            $paramValue = $splitParams[$x + 1]
            foreach ($paramName in $paramNames) {
                ConvertTo-Curl2PSParameter -ParamName $paramName -ParamValue $paramValue
            }
        } elseif ($splitParams[$x].Trim() -match '^https?\:\/\/') {
            # the url in curl is the last parameter, so we need to check if it is a valid URL
            [System.Uri]$uri = $splitParams[$x]
            if ($uri.UserInfo.Length -gt 0) {

                ConvertTo-Curl2PSParameter -ParamName 'u' -ParamValue $uri.UserInfo

                [System.Uri]$uri = $uri.OriginalString -replace "$($uri.UserInfo)@", ''
            }
            [Curl2PSParameterDefinition]@{
                Type          = 'String'
                ParameterName = 'Uri'
                Value         = $uri.OriginalString
            } 
        }
    }

    # if no explicit method, assume GET
    if ($parameters.ParameterName -notcontains 'Method') {
        $parameters += [Curl2PSParameterDefinition]@{
            Type          = 'String'
            ParameterName = 'Method'
            Value         = 'Get'
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'splat') {
        # generate a splat representation of the parameters
        ConvertTo-Curl2PSSplat -Parameters $parameters
    } elseif ($PSCmdlet.ParameterSetName -eq 'string') {
        # generate a string representation of the Invoke-RestMethod command
        ConvertTo-Curl2PSString -Parameters $parameters
    } elseif ($PSCmdlet.ParameterSetName -eq 'raw') {
        $parameters
    }
}