Function ConvertTo-IRM {
    [cmdletbinding()]
    param (
        [curlcommand]$CurlCommand,
        [switch]$String
    )
    if($String.IsPresent){
        $CurlCommand.ToIRM()
    } else {
        $CurlCommand.ToIRMSplat()
    }
}
Function Get-CurlCommand {
    param (
        [ValidateScript({$_.ToLower() -match '^curl '})]
        [string]$CurlString
    )
    [curlcommand]::new($CurlString)
}
Function Get-URLData {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Url,
    
        [Switch]
        $IsValidURL
    )
    [System.Uri]::new($Url)
} 
    
Function ConvertTo-HtString {
    param (
        [hashtable]$InputObject
    )
    $strKeys = @()
    foreach ($key in $InputObject.Keys){
        $strKeys += "    '$key' = '$($InputObject[$key])'"
    }
    $str = "@{`n" + ($strKeys -join "`n") + "`n}"
    $str
}
Class CurlCommand {
    [string]$RawCommand
    [string]$Body
    [System.Uri]$URL
    [string]$Method
    [hashtable]$Headers = @{}
    [bool]$Verbose = $false

    CurlCommand(
        [string]$curlString
    ){
        # This is only going to work on Windows I think...
        if ($curlString -match "`r`n") {
            $arr = $curlString -split "`r`n"
            $curlString = ($arr | foreach-object {$_.TrimEnd('\').TrimEnd(' ')}) -join ' '
        }
        $this.RawCommand = $curlString
        # Set the default method in case one isn't set later
        $this.Method = 'Get'

        $splitParams = [Microsoft.CodeAnalysis.CommandLineParser]::SplitCommandLineIntoArguments($curlString,$true)
        if ($splitParams[0].ToLower() -ne 'curl') {
            Throw "curlString does not start with 'curl'. It needs to."
        }
        for($x=1; $x -lt $splitParams.Count; $x++) {
            # If this item is a parameter name, use it
            # The next item must be the parameter value
            # Unless the current item is a switch param
            # If not, increment $x so we skip the next one
            if ($splitParams[$x] -like '-*') {
                $paramName = $splitParams[$x].TrimStart('-')
                $paramValue = $splitParams[$x+1]
                switch ($paramName.ToLower()){
                    {'h','header' -contains $_} {
                        # Headers
                        $split = ($paramValue.Split(':') -replace '\\"','"')
                        $this.headers[($split[0].Trim())] = (($split[1..$($split.count)] -join ':').Trim())
                        $x++
                    }
                    {'X','request' -contains $_} {
                        # Request type
                        $this.Method = $paramValue.Trim()
                        $x++
                    }
                    {'v','verbose' -contains $_} {
                        # Verbosity
                        $this.Verbose = $true
                    }
                    {'d','data' -contains $_} {
                        # Body
                        $this.body = $paramValue.Trim() -replace '\\"','"'
                        $x++
                    }
                    default {
                        # Unknown
                        Throw "Unknown parameter: $($paramName). Cannot continue."
                    }
                }
            } elseif ($splitParams[$x] -match '^https?\:\/\/') {
                # Must be a url
                $this.URL = $splitParams[$x]
            }
        }

        # Check the url for basic auth
        if ($this.URL.UserInfo -like '*:*'){
            $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this.URL.UserInfo))
            $urlNoAuth = $this.URL.OriginalString -replace "$($this.URL.UserInfo)@",''
            $this.URL = [System.Uri]::new($urlNoAuth)
            $this.Headers['Authorization'] = "Basic $encodedAuth"
        }
    }

    [string] ToString(){
        return $this.RawCommand
    }

    [string] ToIRM(){
        $outString = 'Invoke-RestMethod'
        $outString += " -Uri '$($this.URL.ToString())'"
        $outString += " -Method $($this.Method)"
        if ($this.Body.Length -gt 0){
            $outString += " -Body '$($this.Body)'"
        }
        $outString += " -Verbose:`$$($this.Verbose.ToString().ToLower())"
        if ($this.Headers.Keys){
            #$outString += " -Headers ('$($this.Headers | ConvertTo-Json -Compress)' | ConvertFrom-Json)"
            $outString += " -Headers $(ConvertTo-HtString $this.Headers)"
        }
        return $outString
    }

    [hashtable] ToIRMSplat(){
        $out = @{}
        $out['Uri'] = $this.URL.ToString()
        $out['Method'] = $this.Method
        if ($this.Body.Length -gt 0){
            $out['Body'] = $this.Body
        }
        if ($this.Headers.Keys){
            $out['Headers'] = $this.Headers
        }
        $out['Verbose'] = $this.Verbose
        return $out
    }
}


#$curlString = 'curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates'
