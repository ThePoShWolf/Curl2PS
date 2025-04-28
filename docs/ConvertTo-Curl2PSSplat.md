---
external help file: Curl2PS-help.xml
Module Name: Curl2PS
online version:
schema: 2.0.0
---

# ConvertTo-Curl2PSSplat

## SYNOPSIS
Converts parsed cURL parameters into a splatted hashtable for use with \`Invoke-RestMethod\` or \`Invoke-WebRequest\`.

## SYNTAX

```
ConvertTo-Curl2PSSplat [-Parameters] <Curl2PSParameterDefinition[]> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The \`ConvertTo-Curl2PSSplat\` function takes an array of \`Curl2PSParameterDefinition\` objects (parsed from a cURL command using Invoke-Curl2PS) and generates a splat hashtable.
This splat is intended to be used directly with \`Invoke-RestMethod\` or \`Invoke-WebRequest\` to perform REST API calls in PowerShell.

The function handles parameters of type \`Hashtable\` by merging multiple values into a single hashtable.
If a value starts with \`Get-Item\`, it resolves the value by executing the command and replacing it with the result (supporting -F / --form in cURL and -Form in PowerShell).
For other parameter types, the function adds the value directly to the hashtable.

## EXAMPLES

### EXAMPLE 1
```powershell
# Convert parsed cURL parameters to a splatted hashtable using Invoke-Curl2PS

$curlString = 'curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"value\"}" https://api.example.com'
Invoke-Curl2PS -CurlString $curlString
```

### EXAMPLE 2
```powershell
# Convert parsed cURL parameters to a splatted hashtable

$curlString = @'
curl -X POST -H "Content-Type:application/json" -d '{\"key\":\"value\"}' https://api.example.com
'@
Invoke-Curl2PS -CurlString $curlString -Raw | ConvertTo-Curl2PSSplat

Name                           Value
----                           -----
ContentType                    {application/json}
Uri                            https://api.example.com
Body                           {\
Method                         POST
```

### EXAMPLE 3
```powershell
# Utilize the splat

$curlString = 'curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"value\"}" https://api.example.com'
$splat = Invoke-Curl2PS -CurlString $curlString -Raw | ConvertTo-Curl2PSSplat
Invoke-RestMethod @splat
```

## PARAMETERS

### -Parameters
An array of \`Curl2PSParameterDefinition\` objects representing the parsed cURL command parameters.
These objects should include details such as the parameter name, type, and value.
It is recommended to generate these objects using the \`Invoke-Curl2PS\` function with the \`-Raw\` parameter.

```yaml
Type: Curl2PSParameterDefinition[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [Curl2PSParameterDefinition[]]
### The function accepts an array of `Curl2PSParameterDefinition` objects as input.
## OUTPUTS

### [hashtable]
### The function outputs a hashtable suitable for splatting with `Invoke-RestMethod` or `Invoke-WebRequest`.
## NOTES
- The function assumes that the input \`Curl2PSParameterDefinition\` objects are properly formatted and valid.
- The easiest way to use this function is to pipe the output of \`Invoke-Curl2PS\` with the \`-Raw\` parameter into it.
- If a parameter of type \`Hashtable\` has multiple values, they are merged into a single hashtable (i.e. Headers).
- If a parameter is of type \`PSCredential\`, the function generates a secure credential object in the output hashtable but will hardcode the password if present in the input.

## RELATED LINKS
