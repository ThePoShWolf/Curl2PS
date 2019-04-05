---
external help file: Curl2PS-help.xml
Module Name: Curl2PS
online version:
schema: 2.0.0
---

# Get-URLData

## SYNOPSIS
This function parses a URL and returns an object with all the detailed information of it

## SYNTAX

```
Get-URLData [-Url] <String> [-IsValidURL] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
PS C:\> Get-UrlData -Url 'https://Google.com/Search'

Name                           Value
----                           -----
FullUrl                        https://Google.com/Search
BaseUrl                        https://Google.com
DomainName                     Google.com
Extension                      .com
BaseName                       Google
Path                           /Search
Protocol                       https
QueryString
Fragment
```

## PARAMETERS

### -Url
{{Fill Url Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsValidURL
{{Fill IsValidURL Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
## OUTPUTS

### Object
## NOTES
v0.3
Author: St ©phane van Gulick

## RELATED LINKS
