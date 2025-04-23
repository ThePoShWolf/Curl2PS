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
    $method = 'Get'

    $splitParams = Invoke-Command -ScriptBlock ([scriptblock]::Create("parse $curlString"))
    if ($splitParams[0] -notin 'curl', 'curl.exe') {
        Throw "`$curlString does not start with 'curl' or 'curl.exe', which is necessary for correct parsing."
    }
    for ($x = 1; $x -lt $splitParams.Count; $x++) {
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
            $paramValue = $splitParams[$x + 1]
            foreach ($paramName in $paramNames) {
                if ($config.Arguments.Keys -ccontains $paramName) {
                    if ($config.Arguments[$paramName] -is [string]) {
                        $paramName = $config.Arguments[$paramName]
                    }
                    $out = $config.Arguments[$paramName].Value.Invoke($paramValue)
                    [pscustomobject]@{
                        Type          = $config.Arguments[$paramName].Type
                        ParameterName = $config.Arguments[$paramName].ParameterName
                        Value         = $out
                    }
                } else {
                    "Does not contain $paramName"
                }
            }
        }
    }
}