Class URL {
    [string]$FullUrl
    [string]$BaseUrl
    [string]$DomainName
    [string]$Extension
    [string]$BaseName
    [string]$Path
    [string]$Protocol
    [string]$QueryString
    [string]$Fragment
        
    URL (
        [string]$urlString
    ){
        $Regex = "(?'FullUrl'(?'BaseUrl'(?'Protocol'https?):\/\/(?'DomainName'(?:www\.)?(?'BaseName'[a-zA-Z0-9@:%_\+~#=-]{2,256})(?'Extension'\.[a-zA-Z]{2,6}\b)?)?)(?'Path'[-a-zA-Z0-9@:%_\+.~#&\/\/=,]+)?)(?'QueryString'\?[a-zA-Z0-9@:%_\+.~?&\/\/=]*)?(?'Fragment'#[a-zA-Z0-9@:%_\+.~#&\/\/=]*)?"
        $null = $urlString -match $Regex
        If($Matches){
            $this.FullUrl = $Matches.FullUrl
            $this.BaseUrl = $Matches.BaseUrl
            $this.DomainName = $Matches.DomainName
            $this.Extension = $Matches.Extension
            $this.BaseName = $Matches.BaseName
            $this.Path = $Matches.Path
            $this.Protocol = $Matches.Protocol
            $this.QueryString = $Matches.QueryString
            $this.Fragment = $Matches.Fragment
        }
    }

    [string] ToString(){
        return $this.FullUrl
    }
}