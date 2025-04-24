Function Invoke-Curl2PS {
    [cmdletbinding()]
    param (
        [string]$CurlString
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
        } elseif ($splitParams[$x] -match '^https?\:\/\/') {
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

    # generate a splat representation of the parameters
    ConvertTo-Curl2PSSplat -Parameters $parameters

    # generate a string representation of the Invoke-RestMethod command
    ConvertTo-Curl2PSString -Parameters $parameters
}

Function ConvertTo-Curl2PSParameter {
    [OutputType([Curl2PSParameterDefinition])]
    param (
        [string]$ParamValue,
        [string]$ParamName
    )
    $config = . .\src\config.ps1
    if ($config.ParameterTransformers.Keys -ccontains $paramName) {
        # if the argument value is a string, locate the correct argument in the config
        if ($config.ParameterTransformers[$paramName] -is [string]) {
            $paramName = $config.ParameterTransformers[$paramName]
        }
        # if the argument is an array, get the one with highest met minimum version
        if ($config.ParameterTransformers[$paramName] -is [array]) {
            $argConfig = $null
            foreach ($argument in $config.ParameterTransformers[$paramName]) {
                if ($null -eq $argConfig -and -not $argument.MinimumVersion) {
                    $argConfig = $argument
                }
                if ($argument.MinimumVersion -and [version]$argument.MinimumVersion -lt $PSVersionTable.PSVersion -and $argument.MinimumVersion -gt $argConfig.MinimumVersion) {
                    $argConfig = $argument
                }
            }
        } else {
            $argConfig = $config.ParameterTransformers[$paramName]
        }
        # minimum version check (i.e. SkipCertificateCheck)
        if ($argConfig.MinimumVersion -and [version]$argConfig.MinimumVersion -gt $PSVersionTable.PSVersion) {
            Write-Warning "The parameter $paramName is not supported in this version of PowerShell. Minimum version required: $($argConfig.MinimumVersion)"
            continue
        }
        # invoke the config's script block to return the value
        $out = Invoke-Command -ScriptBlock $argConfig.Value -ArgumentList $paramValue
        $data = [Curl2PSParameterDefinition]@{
            Type          = $argConfig.Type
            ParameterName = $argConfig.ParameterName
            Value         = $out
        }
        # headers are a special case, as they are a hashtable of key/value pairs and sometimes represent other parameters for Invoke-RestMethod
        if ($data.ParameterName -eq 'Headers' -and $config.Headers.Keys -contains $data.Value.Keys[0]) {
            $key = $data.Value.Keys[0]
            if ($config.Headers[$key].Keys -notcontains 'MinimumVersion' -or [version]$config.Headers[$key].MinimumVersion -lt $PSVersionTable.PSVersion) {
                $data = [Curl2PSParameterDefinition]@{
                    Type          = $config.Headers[$key].Type
                    ParameterName = $config.Headers[$key].ParameterName
                    Value         = $data.Value.Values[0]
                }
            }
        }
        $data
        if ($argConfig.AdditionalParameters) {
            foreach ($addParam in $argConfig.AdditionalParameters) {
                [Curl2PSParameterDefinition]@{
                    Type          = $addParam.Type
                    ParameterName = $addParam.ParameterName
                    Value         = Invoke-Command -ScriptBlock $addParam.Value -ArgumentList $paramValue
                }
            }
        }
    } else {
        "Does not contain $paramName"
    }
}