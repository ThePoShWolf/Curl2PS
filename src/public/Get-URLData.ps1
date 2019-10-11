Function Get-URLData {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Url,
    
        [Switch]
        $IsValidURL
    )
    [System.Uri]::new($Url)
} 
    