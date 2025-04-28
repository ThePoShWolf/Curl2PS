---
external help file: Curl2PS-help.xml
Module Name: Curl2PS
online version:
schema: 2.0.0
---

# ConvertTo-Curl2PSString

## SYNOPSIS
Converts a parsed cURL command into a PowerShell \`Invoke-RestMethod\` string representation.

## SYNTAX

```
ConvertTo-Curl2PSString [-Parameters] <Curl2PSParameterDefinition[]> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The \`ConvertTo-Curl2PSString\` function takes an array of \`Curl2PSParameterDefinition\` objects (parsed from a cURL command using Invoke-Curl2PS) and generates a PowerShell string representation of the \`Invoke-RestMethod\` command.
This is useful for converting cURL commands into PowerShell scripts for REST API interactions.

## EXAMPLES

### EXAMPLE 1
```powershell
# Convert a parsed cURL command to a PowerShell string using Invoke-Curl2PS

$curlString = 'curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"value\"}" https://api.example.com'
Invoke-Curl2PS -CurlString $curlString -AsString
```

### EXAMPLE 2
```powershell
# Convert a parsed cURL command to a PowerShell string

$curlString = 'curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"value\"}" https://api.example.com'
Invoke-Curl2PS -CurlString $curlString -Raw | ConvertTo-Curl2PSString
```

### EXAMPLE 3
```powershell
# Use the generated string in a script

$curlString = 'curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"value\"}" https://api.example.com'
$commandString = Invoke-Curl2PS -CurlString $curlString -Raw | ConvertTo-Curl2PSString
Invoke-Expression $commandString
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

### [string]
### The function outputs a string representation of the `Invoke-RestMethod` command.
## NOTES
- The function assumes that the input \`Curl2PSParameterDefinition\` objects are properly formatted and valid.
- The easiest way to use this function is to pipe the output of \`Invoke-Curl2PS\` with the \`-Raw\` parameter into it.
- If a parameter is of type \`PSCredential\`, the function generates a secure credential object in the output string but will hardcode the password if present in the input.
- If a parameter is a hashtable, it is converted to a PowerShell hashtable string using the \`ConvertTo-HashtableString\` private function.

## RELATED LINKS
