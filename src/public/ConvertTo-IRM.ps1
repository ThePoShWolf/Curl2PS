Function ConvertTo-IRM {
    param (
        [ValidateScript({$_.ToLower() -match '^curl '})]
        [string]$CurlString
    )
    $workingStr = $CurlString -replace '^curl\s+',''
    # Match the parameter name
    While ($workingStr -match '^\-{1,2}(?<param>[^\s]+)'){
        switch ($Matches.param) {
            {'H','header' -contains $_} {
                "Header"
            }
            {'X','request' -contains $_} {
                "Method"
            }
            default {
                "unknown"
            }
        }
        $parameterLength = $Matches[0].Length

        # Match parameter value
        if ($workingStr -match '\s\-\S'){
            $index = $workingStr.IndexOf($Matches[0])
        } else {
            $index = $workingStr.Length-1
        }

        $parameterValue = $workingStr.Substring(0,$index)
        $parameterValue.Substring($parameterLength).Trim()

        $workingStr = $workingStr.Substring($index).Trim()
    }
}

curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates