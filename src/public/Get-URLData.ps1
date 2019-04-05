Function Get-URLData {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Url,
    
        [Switch]
        $IsValidURL
    )
    [url]::new($Url)
} 
    