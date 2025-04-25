Class Curl2PSParameterTransformer {
    [version]$MinimumVersion
    [string]$ParameterName
    [string]$Type
    [scriptblock]$Value
    [string]$Warning
    [Curl2PSParameterTransformer]$AdditionalParameters

    Curl2PSArgumentDefinition() {}
}