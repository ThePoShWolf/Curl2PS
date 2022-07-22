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
    ) {
        # Split at platform-dependent NewLine
        if ($curlString -match "\n") {
            $arr = $curlString -split "\n"
            $curlString = ($arr | ForEach-Object { $_.TrimEnd('\').TrimEnd(' ') }) -join ' '
        }
        $this.RawCommand = $curlString
        # Set the default method in case one isn't set later
        $this.Method = 'Get'

        $splitParams = Invoke-Command -ScriptBlock ([scriptblock]::Create("parse $curlString"))
        if ($splitParams[0].ToLowerInvariant() -ne 'curl') {
            Throw "`$curlString does not start with 'curl', which is necessary for correct parsing."
        }
        for ($x = 1; $x -lt $splitParams.Count; $x++) {
            # If this item is a parameter name, use it
            # The next item must be the parameter value
            # Unless the current item is a switch param
            # If not, increment $x so we skip the next one
            if ($splitParams[$x] -like '-*') {
                [string[]]$paramNames = $splitParams[$x].TrimStart('-')
                if ($splitParams[$x] -match '^-[a-zA-Z]+') {
                    # multiple single char flags
                    [string[]]$paramNames = $paramNames[0][0..$paramNames[0].Length]
                }
                $paramValue = $splitParams[$x + 1]
                foreach ($paramName in $paramNames) {
                    switch ($paramName) {
                        { 'H', 'header' -ccontains $_ } {
                            # Headers
                            $split = ($paramValue.Split(':') -replace '\\"', '"')
                            $this.Headers[($split[0].Trim())] = (($split[1..$($split.count)] -join ':').Trim())
                            $x++
                        }
                        { 'X', 'request' -ccontains $_ } {
                            # Request type
                            $this.Method = $paramValue.Trim()
                            $x++
                        }
                        { 'v', 'verbose' -ccontains $_ } {
                            # Verbosity
                            $this.Verbose = $true
                        }
                        { 'd', 'data' -ccontains $_ } {
                            # Body
                            if ($paramValue.Length -gt 0) {
                                $this.Body = $paramValue.Trim() -replace '\\"', '"'
                            }
                            $x++
                        }
                        { 'u', 'user' -ccontains $_ } {
                            # Username
                            if ($_ -like '*:*') {
                                Add-BasicAuth -CurlCommand $this -Auth $paramValue
                            } else {
                                $this.User = $paramValue.Trim()
                            }
                            $x++
                        }
                        'url' {
                            $x++
                            $this.URL = $paramValue.Trim()
                        }
                        { 'abstract-unix-socket', 'alt-svc', 'anyauth', 'a', 'append', 'aws-sigv4', 'basic', 'cacert', 'capath', 'cert-status', 'cert-type', 'E', 'cert', 'ciphers', 'compressed-ssh', 'compressed', 'K', 'config', 'connect-timeout', 'connect-to', 'C', 'continue-at', 'c', 'cookie-jar', 'b', 'cookie', 'create-dirs', 'create-file-mode', 'crlf', 'crlfile', 'curves', 'data-ascii', 'data-binary', 'data-raw', 'data-urlencode', 'delegation', 'digest', 'disable-eprt', 'disable-epsv', 'q', 'disable', 'disallow-username-in-url', 'dns-interface', 'dns-ipv4-addr', 'dns-ipv6-addr', 'dns-servers', 'doh-cert-status', 'doh-insecure', 'doh-url', 'D', 'dump-header', 'egd-file', 'engine', 'etag-compare', 'etag-save', 'expect100-timeout', 'fail-early', 'fail-with-body', 'f', 'fail', 'false-start', 'form-escape', 'form-string', 'F', 'form', 'ftp-account', 'ftp-alternative-to-user', 'ftp-create-dirs', 'ftp-method', 'ftp-pasv', 'P', 'ftp-port', 'ftp-pret', 'ftp-skip-pasv-ip', 'ftp-ssl-ccc-mode', 'ftp-ssl-ccc', 'ftp-ssl-control', 'G', 'get', 'g', 'globoff', 'happy-eyeballs-timeout-ms', 'haproxy-protocol', 'I', 'head', 'h', 'help', 'hostpubmd5', 'hostpubsha256', 'hsts', 'http0.9', '0', 'http1.0', 'http1.1', 'http2-prior-knowledge', 'http2', 'http3', 'ignore-content-length', 'i', 'include', 'k', 'insecure', 'interface', '4', 'ipv4', '6', 'ipv6', 'json', 'j', 'junk-session-cookies', 'keepalive-time', 'key-type', 'key', 'krb', 'libcurl', 'limit-rate', 'l', 'list-only', 'local-port', 'location-trusted', 'L', 'location', 'login-options', 'mail-auth', 'mail-from', 'mail-rcpt-allowfails', 'mail-rcpt', 'M', 'manual', 'max-filesize', 'max-redirs', 'm', 'max-time', 'metalink', 'negotiate', 'netrc-file', 'netrc-optional', 'n', 'netrc', ':', 'next', 'no-alpn', 'N', 'no-buffer', '#', 'progress-bar', 'no-clobber', 'no-keepalive', 'no-npn', 'no-progress-meter', 'no-sessionid', 'noproxy', 'ntlm-wb', 'ntlm', 'oauth2-bearer', 'output-dir', 'o', 'output', 'parallel-immediate', 'parallel-max', 'Z', 'parallel', 'pass', 'path-as-is', 'pinnedpubkey', 'post301', 'post302', 'post303', 'preproxy', 'proto-default', 'proto-redir', 'proto', 'proxy-anyauth', 'proxy-basic', 'proxy-cacert', 'proxy-capath', 'proxy-cert-type', 'proxy-cert', 'proxy-ciphers', 'proxy-crlfile', 'proxy-digest', 'proxy-header', 'proxy-insecure', 'proxy-key-type', 'proxy-key', 'proxy-negotiate', 'proxy-ntlm', 'proxy-pass', 'proxy-pinnedpubkey', 'proxy-service-name', 'proxy-ssl-allow-beast', 'proxy-ssl-auto-client-cert', 'proxy-tls13-ciphers', 'proxy-tlsauthtype', 'proxy-tlspassword', 'proxy-tlsuser', 'proxy-tlsv1', 'U', 'proxy-user', 'x', 'proxy', 'proxy1.0', 'p', 'proxytunnel', 'pubkey', 'Q', 'quote', 'random-file', 'r', 'range', '500', 'rate', 'raw', 'e', 'referer', 'J', 'remote-header-name', 'remote-name-all', 'O', 'remote-name', 'R', 'remote-time', 'remove-on-error', 'request-target', 'resolve', 'retry-all-errors', 'retry-connrefused', 'retry-delay', 'retry-max-time', 'retry', 'sasl-authzid', 'sasl-ir', 'service-name', 'S', 'show-error', 's', 'silent', 'socks4', 'socks4a', 'socks5-basic', 'socks5-gssapi-nec', 'socks5-gssapi-service', 'socks5-gssapi', 'socks5-hostname', 'socks5', 'Y', 'speed-limit', 'y', 'speed-time', 'ssl-allow-beast', 'ssl-auto-client-cert', 'ssl-no-revoke', 'ssl-reqd', 'ssl-revoke-best-effort', 'ssl', '2', 'sslv2', '3', 'sslv3', 'stderr', 'styled-output', 'suppress-connect-headers', 'tcp-fastopen', 'tcp-nodelay', 't', 'telnet-option', 'tftp-blksize', 'tftp-no-options', 'z', 'time-cond', 'tls-max', 'tls13-ciphers', 'tlsauthtype', 'tlspassword', 'tlsuser', 'tlsv1.0', 'tlsv1.1', 'tlsv1.2', 'tlsv1.3', '1', 'tlsv1', 'tr-encoding', 'trace-ascii', 'trace-time', 'trace', 'unix-socket', 'T', 'upload-file', 'B', 'use-ascii', 'A', 'user-agent', 'V', 'version', 'w', 'write-out', 'xattr' -ccontains $_ } {
                            # Valid, yet-unsupported parameters
                            # retrieved from curl.se/docs/manpage.html using console script
                            # ```js
                            #  var params = new Set();
                            #  document.querySelectorAll("body > div.main > div.contents > p > span").forEach( function(e){ setTimeout( function(){ var param = e.innerText.match(/(?<=^--|^-).+/g); if(param){ var splitParam = param[0].split(', '); if (splitParam.length > 1) { splitParam.forEach( function(n){ params.add(n.replace(/^-+/g,'').replace(/\s.+$/g,'')) } )} else {params.add(splitParam[0].replace(/^-+/g,'').replace(/\s.+$/g,''))} } }, 300  ) }  )
                            #  var currentParams = new Set(['H', 'header', 'X', 'request', 'v', 'verbose', 'd', 'data', 'u', 'user'])
                            #  params = new Set([...params].filter(x => !currentParams.has(x)))
                            # ```
                            # Then output the result:
                            # ```js
                            #  Array.from(params).join("','")
                            # ```
                            Write-Verbose "The current version of the module does not support '-$paramName'; however, future releases may implement this."
                            Write-Information -MessageData "The parameter '-$paramName', although supplied, will not be sent to the IWR, because this feature is not yet implemented." -Tags 'Params'
                            Write-Warning -Message "The parameter '-$paramName' is not yet supported. Please refer to curl man pages: https://curl.se/docs/manpage.html"
                        }
                        default {
                            # Unknown
                            Throw "Unknown parameter: '$paramName'. Cannot continue."
                        }
                    }
                }
            } elseif ($splitParams[$x] -match '^https?\:\/\/') {
                # Must be a url
                $this.URL = $splitParams[$x]
            }
        }

        # Check the url for basic auth
        if ($this.URL.UserInfo.Length -gt 1) {
            $this.AddBasicAuth($this.URL.UserInfo)
        }
    }

    AddBasicAuth(
        [string]$Auth
    ) {
        $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Auth))
        $urlNoAuth = $this.URL.OriginalString -replace "$($Auth)@", ''
        $this.URL = [System.Uri]::new($urlNoAuth)
        $this.Headers['Authorization'] = "Basic $encodedAuth"
    }

    [string] ToString() {
        return $this.RawCommand
    }

    [string] ToIRM() {
        $outString = 'Invoke-RestMethod'
        $outString += " -Method $($this.Method)"
        $outString += " -Uri '$($this.URL.ToString())'"
        if ($this.User.Length -gt 0) {
            $outString += " $($this.User)"
        }
        $outString += " -Verbose:`$$($this.Verbose.ToString().ToLowerInvariant())"
        if ($this.Headers.Keys) {
            #$outString += " -Headers ('$($this.Headers | ConvertTo-Json -Compress)' | ConvertFrom-Json)"
            $outString += " -Headers $(ConvertTo-HashtableString $this.Headers)"
        }
        if ($this.Body.Length -gt 0) {
            $outString += " -Body '$($this.Body)'"
        }
        return $outString
    }

    [hashtable] ToIRMSplat() {
        $out = @{}
        $out['Method'] = $this.Method
        $out['Uri'] = $this.URL.ToString()
        if ($this.User.Length -gt 0) {
            # will prompt for password
            $out['Credential'] = $this.User
        }
        if ($this.Body.Length -gt 0) {
            $out['Body'] = $this.Body
        }
        if ($this.Headers.Keys) {
            $out['Headers'] = $this.Headers
        }
        $out['Verbose'] = $this.Verbose
        return $out
    }
}
