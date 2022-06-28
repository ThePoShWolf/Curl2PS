---
external help file: Curl2PS-help.xml
Module Name: Curl2PS
online version:
schema: 2.0.0
---

# Get-CurlCommand

## SYNOPSIS
Converts the curl command into the module's internal CurlCommand class. Useful for debugging.

## SYNTAX

```
Get-CurlCommand [[-CurlString] <String>]
```

## DESCRIPTION
Converts the curl command into the module's internal CurlCommand class. Useful for debugging.

## EXAMPLES

### Example 1
```powershell
PS> $str = 'curl -X GET https://server/api/path -H "Accept: application/json" -H "Authorization: Bearer {{token}}"'
PS> Get-CurlCommand -CurlString $str

Headers    : {Accept, Authorization}
Verbose    : False
RawCommand : curl -X GET https://server/api/path -H "Accept: application/json" -H "Authorization: Bearer {{token}}"
User       : 
Body       : 
URL        : https://server/api/path
Method     : GET
```

Returns the Curl string as the internal object class.

## PARAMETERS

### -CurlString
The curl string to format as a CurlCommand object

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### CurlCommand

## NOTES

## RELATED LINKS
