$script:config = @{
    ParameterTransformers = @{
        "H"        = [Curl2PSParameterTransformer]@{
            ParameterName = "Headers"
            Description   = "Headers are passed to curl as name:value and Invoke-RestMethod takes them as a hashtable."
            Type          = "Hashtable"
            Value         = {
                $split = ($args[0].Split(':') -replace '\\"', '"')
                @{
                    ($split[0].Trim()) = (($split[1..$($split.count)] -join ':').Trim())
                }
            }
        }
        "header"   = "H"
        "X"        = [Curl2PSParameterTransformer]@{
            ParameterName = "Method"
            Description   = "Method is simply a string."
            Type          = "String"
            Value         = {
                $args[0].Trim()
            }
        }
        "request"  = "X"
        "d"        = [Curl2PSParameterTransformer]@{
            ParameterName = "Body"
            Description   = "Body is a string, some curl json escapes the double quote, so that is removed."
            Type          = "String"
            Value         = {
                $args[0].Trim() -replace '\\"', '"'
            }
        }
        "data"     = "d"
        "url"      = [Curl2PSParameterTransformer]@{
            ParameterName = "Uri"
            Description   = "Uri is simply a string."
            Type          = "String"
            Value         = {
                $args[0].Trim()
            }
        }
        "k"        = [Curl2PSParameterTransformer]@{
            MinimumVersion = "6.0"
            ParameterName  = "SkipCertificateCheck"
            Description    = "If -k or --insecure is present, -SkipCertificateCheck is always true."
            Type           = "Switch"
            Value          = {
                $true
            }
        }
        "insecure" = "k"
        "v"        = [Curl2PSParameterTransformer]@{
            ParameterName = "Verbose"
            Description   = "If -v or --verbose is present, use -Verbose in Invoke-RestMethod."
            Type          = "Switch"
            Value         = {
                $true
            }
        }
        "verbose"  = "v"
        "u"        = @(
            [Curl2PSParameterTransformer]@{
                ParameterName = "Headers"
                Description   = "Supported in all versions of PowerShell, we can convert basic auth to an Authorization header and pass that."
                Type          = "Hashtable"
                Value         = {
                    $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($args[0]))
                    @{
                        Authorization = "Basic $encodedAuth"
                    }
                }
            },
            [Curl2PSParameterTransformer]@{
                MinimumVersion       = "7.0"
                ParameterName        = "Credential"
                Description          = "Starting in PowerShell 7.0 (unsure on version), basic auth can be passed using a combination of -Credential and '-Authentication Basic'"
                Type                 = "PSCredential"
                Value                = {
                    $user = $args[0]
                    if ($user -like '*:*') {
                        $split = $user.Split(':')
                        if ($split[1].Length -gt 0) {
                            [pscredential]::new($split[0], (ConvertTo-SecureString $split[1] -AsPlainText -Force))
                        } else {
                            [pscredential]::new($split[0], [securestring]::new())
                        }
                    } else {
                        Write-Warning "Unable to handle the user authentication value. Unrecognized format."
                    }
                }
                AdditionalParameters = @{
                    ParameterName = "Authentication"
                    Type          = "String"
                    Value         = {
                        "Basic"
                    }
                }
            }
        )
        "user"     = "u"
        "F"        = [Curl2PSParameterTransformer]@{
            MinimumVersion = "7.0"
            ParameterName  = "Form"
            Description    = "Form is passed as '-F name=value' in curl and needs to be converted to a hashtable for PowerShell."
            Type           = "Hashtable"
            Value          = {
                $ht = @{}
                $formData = $args[0].TrimStart('"').TrimEnd('"')
                $split = $formData.Split('=')
                $split[1] = $split[1] -replace '@', 'Get-Item '
                if ($split[1] -like '{*}') {
                    $ht[$split[0]] = $split[1] | ConvertFrom-Json -AsHashtable
                } else {
                    $ht[$split[0]] = $split[1]
                }
                $ht
            }
            Warning        = "Form support needs testing! If this works or not, please share your feedback: https://github.com/theposhwolf/curl2ps/issues"
        }
        "form"     = "F"
    }
    Headers               = @{
        "Content-Type" = @{
            MinimumVersion = "7.0"
            ParameterName  = "ContentType"
            Type           = "String"
        }
    }
}