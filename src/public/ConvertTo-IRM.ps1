Function ConvertTo-IRM {
    param (
        [ValidateScript({$_.ToLower() -match '^curl '})]
        [string]$CurlString
    )
    # variables
    $headers = @{}

    # Match the url
    # regex from: https://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
    $CurlString -match 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)'
    $url = $Matches[0]

    $workingStr = $CurlString -replace '^curl\s+','' -replace $url,''

    If($url -match 'https?:\/\/(?<up>[^@]+)@'){
        $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Matches.up))
        $headers['Authorization'] = "Basic $encodedAuth"
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

        switch ($parameterName){
            {'H','header' -contains $_} {
                $parameterValue = $parameterValue -replace "^['`"]",''
                $parameterValue = $parameterValue -replace "['`"]$",''
                $split = $parameterValue.Split(':')
                $headers[$split[0]] = $split[1]
            }
            {'X','request' -contains $_} {
                "Method"
            }
            {'v','verbose' -contains $_} {
                "Verbose"
            }
            {'d','data'} {
                $parameterValue = $parameterValue -replace "^['`"]",''
                $parameterValue = $parameterValue -replace "['`"]$",''
                $body = $parameterValue
            }
            default {
                "unknown: $($parameterName)"
            }
        }

        $workingStr = $workingStr.Substring($index).Trim()
    }
}

<#
#curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates

$CurlString = @"
curl -v -X PATCH https://api.airtable.com/v0/appBLvHFF78kERCvW/Payees/recMvdJuoL6ivDA9I -H "Authorization: Bearer YOUR_API_KEY" -H "Content-Type: application/json" -d '{"fields": {"Name": "Eugene Water and Electric Board"}}'
"@

$CurlString = 'curl --request GET "https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json" \  --data ""'

$url = "https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json"
$url -match 'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)'

#>