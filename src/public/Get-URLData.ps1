Function Get-URLData {
    <#
    .SYNOPSIS
        This function parses a URL and returns an object with all the detailed information of it
    .DESCRIPTION
        Long description
    .EXAMPLE

        Get-UrlData -Url 'https://Google.com/Search'

        #returns the following object

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


    .INPUTS
        String
    .OUTPUTS
        Object
    .NOTES
        v0.3
        Author: Stéphane van Gulick
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Url,
    
        [Switch]
        $IsValidURL
    )
    $Regex = "(?'FullUrl'(?'BaseUrl'(?'Protocol'https?):\/\/(?'DomainName'(?:www\.)?(?'BaseName'[a-zA-Z0-9@:%_\+~#=-]{2,256})(?'Extension'\.[a-zA-Z]{2,6}\b)?)?)(?'Path'[-a-zA-Z0-9@:%_\+.~#&\/\/=,]+)?)(?'QueryString'\?[a-zA-Z0-9@:%_\+.~?&\/\/=]*)?(?'Fragment'#[a-zA-Z0-9@:%_\+.~#&\/\/=]*)?"
    $Null =$Url -match $Regex
    
    If($Matches){
        $Hash = [Ordered]@{}
        $Hash.FullUrl = $Matches.FullUrl
        $Hash.BaseUrl = $Matches.BaseUrl
        $Hash.DomainName = $Matches.DomainName
        $Hash.Extension = $Matches.Extension
        $Hash.BaseName = $Matches.BaseName
        $Hash.Path = $Matches.Path
        $Hash.Protocol = $Matches.Protocol
        $Hash.QueryString = $Matches.QueryString
        $Hash.Fragment = $Matches.Fragment
        Return New-Object psobject -ArgumentList $Hash
        
    }

} 
    