---
external help file: Curl2PS-help.xml
Module Name: Curl2PS
online version:
schema: 2.0.0
---

# ConvertTo-IRM

## SYNOPSIS
Converts a CURL command to an Invoke-RestMethod command

## SYNTAX

### asSplat (Default)
```
ConvertTo-IRM [-CurlCommand <CurlCommand>] [<CommonParameters>]
```

### asString
```
ConvertTo-IRM [-CurlCommand <CurlCommand>] [-CommandAsString] [<CommonParameters>]
```

## DESCRIPTION
Takes a curl command as a string and converts it to Invoke-RestMethod syntax.

If you find unsupported parameters, please open an issue in Github: https://github.com/theposhwolf/curl2ps. PRs welcome!

## EXAMPLES

### Example 1
```powershell
PS> $str = 'curl -X GET https://server/api/path -H "Accept: application/json" -H "Authorization: Bearer {{token}}"'
PS> ConvertTo-IRM $str

Name                           Value
----                           -----
Headers                        {Accept, Authorization}
Uri                            https://server/api/path
Method                         GET
Verbose                        False
```

The default output of ConvertTo-IRM is to output a hash table that you can pass into Invoke-RestMethod.

### Example 2
```powershell
PS> $str = 'curl -X GET https://server/api/path -H "Accept: application/json" -H "Authorization: Bearer {{token}}"'
PS> ConvertTo-IRM $str -CommandAsString

Invoke-RestMethod -Method GET -Uri 'https://server/api/path' -Verbose:$false -Headers @{
    'Accept' = 'application/json'
    'Authorization' = 'Bearer {{token}}'
}
```

If you use the -CommandAsString parameter, you'll get output equivalent to what the Invoke-RestMethod command would look like.

## PARAMETERS

### -CommandAsString
Sets the output to be a string instead of a splat.

```yaml
Type: SwitchParameter
Parameter Sets: asString
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CurlCommand
The curl command to be converted to Invoke-RestMethod

```yaml
Type: CurlCommand
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Collections.Hashtable

### System.String

## NOTES

## RELATED LINKS
