# Curl2PS

My goal with this repo is be able to easily convert curl commands to Invoke-RestMethod syntax for PowerShell consumption.

Currently, it is a simple function, ```ConvertTo-IRM```, that works with simple curl examples such as:

```PowerShell
$CurlString = @"
curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates
"@

PS> ConvertTo-IRM $CurlString

Invoke-RestMethod -Method GET -Headers ('{"Content-Type":"application/json","X-Auth-Key":"61e5f04ca1794253ed17e6bb986c1702","Accept":"application/json","X-Auth-Workspace":"demo.example@actualreports.com","X-Auth-Signature":""}' | ConvertFrom-Json)
```

Or

```PowerShell
PS> ConvertTo-IRM -CurlString 'curl --request GET "https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json" \  --data ""'

Invoke-RestMethod -Method GET  \ -Body "" -Headers ('{"Authorization":"Basic bmNnMWluLThkMXJhZzo1bnVhdXpqNXBrZmZ0bHozZm15a3NteWhhdDZqMzVrZg=="}' | ConvertFrom-Json)
```