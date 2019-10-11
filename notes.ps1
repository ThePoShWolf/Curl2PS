[Microsoft.CodeAnalysis.CommandLineParser]::SplitCommandLineIntoArguments('curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates',$true)
[Microsoft.CodeAnalysis.CommandLineParser]::SplitCommandLineIntoArguments

[System.Uri]::new('https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json')