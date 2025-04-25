Function ConvertTo-Curl2PSParameter {
    [OutputType([Curl2PSParameterDefinition])]
    param (
        [string]$ParamValue,
        [string]$ParamName
    )
    $config = . .\src\config.ps1
    if ($config.ParameterTransformers.Keys -ccontains $paramName) {
        # if the argument value is a string, locate the correct argument in the config
        $ogParamName = $paramName
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
            Write-Warning "The parameter $ogParamName is not supported in this version of PowerShell. Minimum version required: $($argConfig.MinimumVersion)"
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
        if ($argConfig.Warning.Length -gt 0) {
            Write-Warning "For param '$($ogParamName)': $($argConfig.Warning)"
        }
    } else {
        Write-Warning "'$paramName' has not yet been implemented."
    }
}