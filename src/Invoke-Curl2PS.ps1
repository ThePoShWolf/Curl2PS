Function Invoke-Curl2PS {
    [cmdletbinding()]
    param (
        [string]$CurlCommand
    )
    $config = . .\src\config.ps1
    if ($curlString -match "\n") {
        $arr = $curlString -split "\n"
        $curlString = ($arr | ForEach-Object { $_.TrimEnd('\').Trim() }) -join ' '
    }

    $splitParams = Invoke-Command -ScriptBlock ([scriptblock]::Create("parse $curlString"))
    if ($splitParams[0] -notin 'curl', 'curl.exe') {
        Throw "`$curlString does not start with 'curl' or 'curl.exe', which is necessary for correct parsing."
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
                if ($config.Arguments.Keys -ccontains $paramName) {
                    # if the argument value is a string, locate the correct argument in the config
                    if ($config.Arguments[$paramName] -is [string]) {
                        $paramName = $config.Arguments[$paramName]
                    }
                    # minimum version check (i.e. SkipCertificateCheck)
                    if ($config.Arguments[$paramName].MinimumVersion -and [version]$config.Arguments[$paramName].MinimumVersion -gt $PSVersionTable.PSVersion) {
                        Write-Warning "The parameter $paramName is not supported in this version of PowerShell. Minimum version required: $($config.Arguments[$paramName].MinimumVersion)"
                        continue
                    }
                    # invoke the config's script block to return the value
                    $out = Invoke-Command -ScriptBlock $config.Arguments[$paramName].Value -ArgumentList $paramValue
                    $data = [pscustomobject]@{
                        Type          = $config.Arguments[$paramName].Type
                        ParameterName = $config.Arguments[$paramName].ParameterName
                        Value         = $out
                    }
                    # headers are a special case, as they are a hashtable of key/value pairs and sometimes represent other parameters for Invoke-RestMethod
                    if ($data.ParameterName -eq 'Headers' -and $config.Headers.Keys -contains $data.Value.Keys[0]) {
                        $key = $data.Value.Keys[0]
                        if ($config.Headers[$key].Keys -notcontains 'MinimumVersion' -or [version]$config.Headers[$key].MinimumVersion -lt $PSVersionTable.PSVersion) {
                            $data = [pscustomobject]@{
                                Type          = $config.Headers[$key].Type
                                ParameterName = $config.Headers[$key].ParameterName
                                Value         = $data.Value.Values[0]
                            }
                        }
                    }
                    $data
                } else {
                    "Does not contain $paramName"
                }
            }
        } elseif ($splitParams[$x] -match '^https?\:\/\/') {
            # the url in curl is the last parameter, so we need to check if it is a valid URL
            [pscustomobject]@{
                Type          = 'String'
                ParameterName = 'Uri'
                Value         = $splitParams[$x]
            }
        }
    }

    # if no explicit method, assume GET
    if ($parameters.ParameterName -notcontains 'Method') {
        $parameters += [pscustomobject]@{
            Type          = 'String'
            ParameterName = 'Method'
            Value         = 'Get'
        }
    }

    # generate a splat representation of the parameters
    $splat = @{}
    foreach ($paramGroup in $parameters | Group-Object ParameterName) {
        if ($paramGroup.Count -gt 1) {
            if ($paramGroup[0].Group[0].Type -eq 'Hashtable') {
                $ht = @{}
                foreach ($pg in $paramGroup.Group) {
                    foreach ($key in $pg.Value.Keys) {
                        $ht[$key] = $pg.Value[$key]
                    }
                }
                $splat[$paramGroup.Name] = $ht
            } else {
                Write-Warning "Multiple values for parameter $($paramGroup.Name) of type $($paramGroup.Group[0].TypeNames) are not supported."
            }
        } else {
            $splat[$paramGroup.Name] = $paramGroup.Group[0].Value
        }
    }
    $splat

    # generate a string representation of the Invoke-RestMethod command
    $baseStr = "Invoke-RestMethod -Uri '$($splat.Uri)' -Method $($splat.Method)"
    foreach ($paramGroup in $parameters | Group-Object ParameterName) {
        if ($('Uri', 'Method') -contains $paramGroup.Name) {
            continue
        }
        if ($paramGroup.Count -gt 1) {
            if ($paramGroup[0].Group[0].Type -eq 'Hashtable') {
                $ht = @{}
                foreach ($pg in $paramGroup.Group) {
                    foreach ($key in $pg.Value.Keys) {
                        $ht[$key] = $pg.Value[$key]
                    }
                }
                $baseStr += " -$($paramGroup.Name) $(ConvertTo-HashtableString $ht)"
            } else {
                Write-Warning "Multiple values for parameter $($paramGroup.Name) of type $($paramGroup.Group[0].TypeNames) are not supported."
            }
        } elseif ($paramGroup[0].Group[0].Type -eq 'Hashtable') {
            $baseStr += " -$($paramGroup.Name) $(ConvertTo-HashtableString $paramGroup.Group[0].Value)"
        } elseif ($paramGroup[0].Group[0].Type -eq 'Switch') {
            $baseStr += " -$($paramGroup.Name):`$$($paramGroup.Group[0].Value.ToString().ToLower())"
        } elseif ($paramGroup[0].Group[0].Type -eq 'String') {
            $baseStr += " -$($paramGroup.Name) '$($paramGroup.Group[0].Value)'"
        } else {
            $baseStr += " -$($paramGroup.Name) $($paramGroup.Group[0].Value)"
        }
    }
    $baseStr
}