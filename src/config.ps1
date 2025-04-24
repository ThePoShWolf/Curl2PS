@{
    Arguments = @{
        "H"        = @{
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
        "X"        = @{
            ParameterName = "Method"
            Type          = "String"
            Value         = {
                $args[0].Trim()
            }
        }
        "request"  = "X"
        "d"        = @{
            ParameterName = "Body"
            Type          = "String"
            Value         = {
                $args[0].Trim() -replace '\\"', '"'
            }
        }
        "data"     = "d"
        "url"      = @{
            ParameterName = "Uri"
            Type          = "String"
            Value         = {
                $args[0].Trim()
            }
        }
        "k"        = @{
            MinimumVersion = "6.0"
            ParameterName  = "SkipCertificateCheck"
            Type           = "Switch"
            Value          = {
                $true
            }
        }
        "insecure" = "k"
        "v"        = @{
            ParameterName = "Verbose"
            Type          = "Switch"
            Value         = {
                $true
            }
        }
        "verbose"  = "v"
        "u"        = @(
            @{
                ParameterName = "Headers"
                Type          = "Hashtable"
                Value         = {
                    $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($args[0]))
                    @{
                        Authorization = "Basic $encodedAuth"
                    }
                }
            },
            @{
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
                        Write-Host "Blah"
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
    }
    Headers   = @{
        "Content-Type" = @{
            MinimumVersion = "7.0"
            ParameterName  = "ContentType"
            Type           = "String"
        }
    }
}