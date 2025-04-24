Class Curl2PSParameterTransformer {
    [version]$MinimumVersion
    [string]$ParameterName
    [string]$Type
    [scriptblock]$Value
    [Curl2PSParameterTransformer]$AdditionalParameters

    Curl2PSArgumentDefinition() {}
}