[Microsoft.CodeAnalysis.CommandLineParser]::SplitCommandLineIntoArguments('curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates',$true)

[Microsoft.CodeAnalysis.CommandLineParser]::SplitCommandLineIntoArguments('curl -X POST https://api.dropboxapi.com/2/paper/docs/download --header "Authorization: Bearer " --header "Dropbox-API-Arg: {\"doc_id\": \"uaSvRuxvnkFa12PTkBv5q\",\"export_format\": \"markdown\"}"',$true)

$uri = [System.Uri]::new('https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json')

$uri = [System.Uri]::new('https://api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json')

$curlCommand = 'curl --request GET "https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json"  --data "--blah" --whatever "value"'

[Microsoft.CodeAnalysis.CommandLineParser]::SplitCommandLineIntoArguments($curlCommand,$true)

$CurlString = @"
curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates
"@

$str = 'curl -X GET https://PlopServer/identity/api/tenants/Woo/subtenants -H "Accept: application/json" -H "Authorization: Bearer {{token}}"'

$irm = ConvertTo-IRM $str -GetParamsAsString