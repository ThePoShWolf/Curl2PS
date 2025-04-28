Class Curl2PSParameterTransformer {
    [string]$Description
    [version]$MinimumVersion
    [string]$ParameterName
    [string]$Type
    [scriptblock]$Value
    [string]$Warning
    [Curl2PSParameterTransformer]$AdditionalParameters

    Curl2PSArgumentDefinition() {}
}