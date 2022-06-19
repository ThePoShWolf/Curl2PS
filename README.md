# Curl2PS

This module is a utility module to help convert curl commands to Invoke-RestMethod syntax.

This module includes classes for dealing with the curl command as well as URLs, but primarily converts curl commands to Invoke-RestMethod syntax with the ```ConvertTo-IRM``` function.

To install the module:

```powershell
Install-Module Curl2PS
```

Usage examples:

```powershell
$CurlString = @"
curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates
"@

PS> $splat = ConvertTo-IRM $CurlString
PS> Invoke-RestMethod @splat
```

Or if you'd prefer the string command:

```powershell
ConvertTo-IRM $CurlString -CommandAsString

Invoke-RestMethod -Uri https://us1.pdfgeneratorapi.com/api/v3/templates -Method GET -Headers @{
    'X-Auth-Key' = '61e5f04ca1794253ed17e6bb986c1702'
    'Accept' = 'application/json'
    'X-Auth-Signature' = ''
    'X-Auth-Workspace' = 'demo.example@actualreports.com'
    'Content-Type' = 'application/json'
}
```

Or another example:

```powershell
PS> ConvertTo-IRM -CurlCommand 'curl --request GET "https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json"  --data ""' -CommandAsString

Invoke-RestMethod -Uri https://api.sherpadesk.com/tickets -Method GET -Headers @{
    'Authorization' = 'Basic bmNnMWluLThkMXJhZzo1bnVhdXpqNXBrZmZ0bHozZm15a3NteWhhdDZqMzVrZg=='
}
```

## Issues

If you find a curl command that doesn't properly convert, please [open an issue](./../../issues)!

PRs welcome!