Class CurlCommand {
    [string]$RawCommand
    [string]$User
    [string]$Body
    [System.Uri]$URL
    [string]$Method
    [hashtable]$Headers = @{}
    [bool]$Verbose = $false

    CurlCommand(
        [string]$curlString
    ){
        # Split at platform-dependent NewLine
        if ($curlString -match "$([System.Environment]::NewLine)") {
            $arr = $curlString -split "$([System.Environment]::NewLine)"
            $curlString = ($arr | ForEach-Object {$_.TrimEnd('\').TrimEnd(' ')}) -join ' '
        }
        $this.RawCommand = $curlString
        # Set the default method in case one isn't set later
        $this.Method = 'Get'

        $splitParams = [Microsoft.CodeAnalysis.CommandLineParser]::SplitCommandLineIntoArguments($curlString,$true)
        if ($splitParams[0].ToLowerInvariant() -ne 'curl') {
            Throw "`$curlString does not start with 'curl', which is necessary for correct parsing."
        }
        for($x=1; $x -lt $splitParams.Count; $x++) {
            # If this item is a parameter name, use it
            # The next item must be the parameter value
            # Unless the current item is a switch param
            # If not, increment $x so we skip the next one
            if ($splitParams[$x] -like '-*') {
                $paramName = $splitParams[$x].TrimStart('-')
                $paramValue = $splitParams[$x+1]
                switch ($paramName){
                    {'H','header' -ccontains $_} {
                        # Headers
                        $split = ($paramValue.Split(':') -replace '\\"','"')
                        $this.Headers[($split[0].Trim())] = (($split[1..$($split.count)] -join ':').Trim())
                        $x++
                    }
                    {'X','request' -ccontains $_} {
                        # Request type
                        $this.Method = $paramValue.Trim()
                        $x++
                    }
                    {'v','verbose' -ccontains $_} {
                        # Verbosity
                        $this.Verbose = $true
                    }
                    {'d','data' -ccontains $_} {
                        # Body
                        $this.Body = $paramValue.Trim() -replace '\\"','"'
                        $x++
                    }
                    {'u','user' -ccontains $_} {
                        # Username
                        if($_ -like '*:*'){
                            Add-BasicAuth -CurlCommand $this -Auth $paramValue
                        } else{
                            $this.User = $paramValue.Trim() 
                        }
                        $x++
                    }
                    {'s','silent' -ccontains $_} {
                        # Silent progress
                    
                    }
                    {'#','progress-bar' -contains $_} {
                        # Progress bar
                    
                    }
                    {'a','append' -ccontains $_} {
                        # Append to the target file instead of overwriting it. If the remote file doesn't exist, it will be created
                    
                    }
                    {'E','cert','K','config','C','continue-at','c','cookie-jar','b','cookie','q','disable','D','dump-header','f','fail','F','form','P','ftp-port','G','get','g','globoff','I','head','h','help','0','http1.0','i','include','k','insecure','4','ipv4','6','ipv6','j','junk-session-cookies','l','list-only','L','location','M','manual','m','max-time','n','netrc',':','next','N','no-buffer','o','output','Z','parallel','#','progress-bar','U','proxy-user','x','proxy','p','proxytunnel','Q','quote','r','range','e','referer','J','remote-header-name','O','remote-name','R','remote-time','S','show-error','Y','speed-limit','y','speed-time','2','sslv2','3','sslv3','t','telnet-option','z','time-cond','1','tlsv1','T','upload-file','B','use-ascii','A','user-agent','V','version','w','write-out' -ccontains $_} {
                        # Valid, yet-unsupported parameters
                            # retrieved from curl.se/docs/manpage.html using console script
                                # ```js
                                    #  var params = new Array();
                                    #  document.querySelectorAll("body > div.main > div.contents > p > span").forEach( function(e){ setTimeout( function(){ var param = e.innerText.match(/(?<=--|-).+/g); if(param){ var splitParam = param[0].split(', '); if (splitParam.length > 1) { splitParam.forEach( function(n){ params.push(n.replace(/^-+/g,'').replace(/\s.+$/g,'')) } )} } }, 300  ) }  )
                                    #  params.join("','")
                                # ```
                        Write-Verbose "The current version of the module does not support '-$paramName'; however, future releases may implement this."
                        Write-Information -MessageData "The parameter '-$paramName', although supplied, will not be sent to the IWR, because this feature is not yet implemented." -Tags 'Params'
                        Write-Warning -Message "The parameter '-$paramName' will not be sent to the IWR."
                    }           
                    default {
                        # Unknown
                        Throw "Unknown parameter: '$paramName'. Cannot continue."
                    }
                }
            } elseif ($splitParams[$x] -match '^https?\:\/\/') {
                # Must be a url
                $this.URL = $splitParams[$x]
            }
        }

        # Check the url for basic auth
        Add-BasicAuth -CurlCommand $this -Auth $($this.URL.UserInfo)
    }

    [string] ToString(){
        return $this.RawCommand
    }

    [string] ToIRM(){
        $outString = 'Invoke-RestMethod'
        $outString += " -Method $($this.Method)"
        $outString += " -Uri '$($this.URL.ToString())'"
        if($this.User.Length -gt 0){
            $outString += " (Get-Credential -UserName '$($this.User)')"
        }
        $outString += " -Verbose:`$$($this.Verbose.ToString().ToLowerInvariant())"
        if ($this.Headers.Keys){
            #$outString += " -Headers ('$($this.Headers | ConvertTo-Json -Compress)' | ConvertFrom-Json)"
            $outString += " -Headers $(ConvertTo-HashtableString $this.Headers)"
        }
        if ($this.Body.Length -gt 0){
            $outString += " -Body '$($this.Body)'"
        }
        return $outString
    }

    [hashtable] ToIRMSplat(){
        $out = @{}
        $out['Method'] = $this.Method
        $out['Uri'] = $this.URL.ToString()
        if($this.User.Length -gt 0){
            # will prompt for password
            $out['Credential'] = $this.User
        }
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