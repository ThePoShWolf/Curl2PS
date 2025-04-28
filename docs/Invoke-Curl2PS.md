---
external help file: Curl2PS-help.xml
Module Name: Curl2PS
online version:
schema: 2.0.0
---

# Invoke-Curl2PS

## SYNOPSIS
Converts a cURL command string into a PowerShell representation, such as a splatted hashtable, a string representation of \`Invoke-RestMethod\`, or raw parameter definitions.

## SYNTAX

### splat (Default)
```
Invoke-Curl2PS [-CurlString] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### string
```
Invoke-Curl2PS [-CurlString] <String> [-AsString] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### raw
```
Invoke-Curl2PS [-CurlString] <String> [-Raw] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The \`Invoke-Curl2PS\` function takes a cURL command string as input and parses it into a PowerShell-friendly format.
It supports three output formats:

- (default) A splat hashtable for use with \`Invoke-RestMethod\` or \`Invoke-WebRequest\`.
- A string representation of the \`Invoke-RestMethod\` command.
- Raw parameter definitions as an array of \`Curl2PSParameterDefinition\` objects. Useful for development and debugging.

This function is useful for converting cURL commands into PowerShell scripts, making it easier to work with REST APIs in PowerShell.

## EXAMPLES

### EXAMPLE 1
```powershell
# Convert a cURL command to a splatted hashtable

$cURL = 'curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"value\"}" https://api.example.com'
$splat = Invoke-Curl2PS -CurlString $cURL
Invoke-RestMethod @splat
```

### EXAMPLE 2
```powershell
# Convert a cURL command to a string representation

$cURL = 'curl -X GET https://api.example.com'
$string = Invoke-Curl2PS -CurlString $cURL -AsString
Write-Output $string
```

### EXAMPLE 3
```powershell
# Get raw parameter definitions from a cURL command

$cURL = 'curl -X DELETE https://api.example.com/resource/123'
$rawParams = Invoke-Curl2PS -CurlString $cURL -Raw

$rawParams | Format-Table -AutoSize

# Convert to a splat
$splat = $rawParams | ConvertTo-Curl2PSSplat

# Convert to a string
$string = $rawParams | ConvertTo-Curl2PSString
```

## PARAMETERS

### -CurlString
The cURL command string to be converted.
This must start with \`curl\` or \`curl.exe\` for proper parsing.

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

### -AsString
Specifies that the output should be a string representation of the \`Invoke-RestMethod\` command.
The string conversion is handled by the \`ConvertTo-Curl2PSString\` function.

```yaml
Type: SwitchParameter
Parameter Sets: string
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Raw
Specifies that the output should be an array of raw parameter definitions (\`Curl2PSParameterDefinition\` objects).

```yaml
Type: SwitchParameter
Parameter Sets: raw
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [string]
### The function accepts a single string input representing the cURL command.
## OUTPUTS

### [hashtable]
### If 'Raw' and 'AsString' are not passed, the function outputs a hashtable suitable for splatting with `Invoke-RestMethod` or `Invoke-WebRequest`.
### [string]
### If the `AsString` parameter is specified, the function outputs a string representation of the `Invoke-RestMethod` command.
### [Curl2PSParameterDefinition[]]
### If the `Raw` parameter is specified, the function outputs an array of `Curl2PSParameterDefinition` objects. These can be piped to ConvertTo-Curl2PSSplat or ConvertTo-Curl2PSString for further processing.
## NOTES
- The function assumes that the cURL command is valid and properly formatted and may fail if the command is malformed.
- If the cURL command contains a URL with user info (e.g., \`https://user:pass@api.example.com\`), the user info is extracted and added as basic authentication.

## RELATED LINKS
