@{
    ParameterTransformers = @{
        "H"        = [Curl2PSParameterTransformer]@{
            ParameterName = "Headers"
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
            Type          = "String"
            Value         = {
                $args[0].Trim()
            }
        }
        "request"  = "X"
        "d"        = [Curl2PSParameterTransformer]@{
            ParameterName = "Body"
            Type          = "String"
            Value         = {
                $args[0].Trim() -replace '\\"', '"'
            }
        }
        "data"     = "d"
        "url"      = [Curl2PSParameterTransformer]@{
            ParameterName = "Uri"
            Type          = "String"
            Value         = {
                $args[0].Trim()
            }
        }
        "k"        = [Curl2PSParameterTransformer]@{
            MinimumVersion = "6.0"
            ParameterName  = "SkipCertificateCheck"
            Type           = "Switch"
            Value          = {
                $true
            }
        }
        "insecure" = "k"
        "v"        = [Curl2PSParameterTransformer]@{
            ParameterName = "Verbose"
            Type          = "Switch"
            Value         = {
                $true
            }
        }
        "verbose"  = "v"
        "u"        = @(
            [Curl2PSParameterTransformer]@{
                ParameterName = "Headers"
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