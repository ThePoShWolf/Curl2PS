# Curl2PS

[![Curl2PS](https://img.shields.io/powershellgallery/v/Curl2PS.svg?style=flat-square&label=Curl2PS "Curl2PS")](https://www.powershellgallery.com/packages/Curl2PS/)

This module is a utility module to help convert curl commands to Invoke-RestMethod syntax.

This module includes classes for dealing with the curl command as well as URLs, but primarily converts curl commands to Invoke-RestMethod syntax with the ```ConvertTo-IRM``` function.

To install the module:

```powershell
Install-Module Curl2PS
```

Usage examples:

```powershell
$CurlString = @"
curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates
"@

PS> $splat = Invoke-Curl2PS $CurlString
PS> Invoke-RestMethod @splat
```

Or if you'd prefer the string command:

```powershell
Invoke-Curl2PS $CurlString -AsString

Invoke-RestMethod -Uri https://us1.pdfgeneratorapi.com/api/v3/templates -Method GET -Headers @{
    'X-Auth-Key' = '61e5f04ca1794253ed17e6bb986c1702'
    'Accept' = 'application/json'
    'X-Auth-Signature' = ''
    'X-Auth-Workspace' = 'demo.example@actualreports.com'
    'Content-Type' = 'application/json'
}
```

Or another example:

```powershell
PS> Invoke-Curl2PS -CurlString 'curl --request GET "https://ncg1in-8d1rag:5nuauzj5pkfftlz3fmyksmyhat6j35kf@api.sherpadesk.com/tickets?status=open,onhold&role=user&limit=6&format=json"  --data ""' -AsString

Invoke-RestMethod -Uri https://api.sherpadesk.com/tickets -Method GET -Headers @{
    'Authorization' = 'Basic bmNnMWluLThkMXJhZzo1bnVhdXpqNXBrZmZ0bHozZm15a3NteWhhdDZqMzVrZg=='
}
```

## Contributing

Each curl parameter that Curl2PS has implemented can be found in [config.ps1](./src/config.ps1). For example, here is the configuration value for headers (`-H` / `--header`):

```powershell
@{
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
}
```

`Invoke-Curl2PS` will search the `ParameterTransformers` hashtable looking for a parameter that matches the curl parameter name. If the value is a string, such as for `header`, then it will look up the referenced value.

The value field of the transformer is represented as a script block and is executed by `Invoke-Curl2PS` using `Invoke-Command` and the value of the parameter is passed via `-ArgumentList` so it is exposed via the `$args` automatic variable. Reference `$args[0]` for the value.

In this example it splits the value on the `:` and then returns it as a hashtable. The `ConvertTo-Curl2PS*` will combine multiple headers.

If you need to list a minimum supported version of PowerShell, look at the user parameter transformer (`-u` / `--user`):

```powershell
@{
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
}
```

`Invoke-Curl2PS` will find the parameter transformer with the highest supported minimum version based on the version of PowerShell that is running `Curl2PS`. If this is executed in `7.5`, for example, it will use the second transformer.

The `AdditionalParameters` property adds additional parameters that need to be included if the select transformer is used. In this example, the transformer will also create an `Authentication` parameter equal to `Basic`.

## Issues

If you find a curl command that doesn't properly convert, please [open an issue](./../../issues)!

PRs welcome!

## Changelog

### 0.2.0

- Complete re-architecture of Curl2PS with the intention of making it more modular and easier to develop.
  - Parameter specific conversions are stored in a dedicated [config.ps1](./src/config.ps1) file with a conversion declared as a scriptblock.
  - `Invoke-Curl2PS` introduces a more PowerShelly approach that outputs an array of Curl2PSParameterDefinition objects that can be piped to `ConvertTo-Curl2PSSplat` and `ConvertTo-Curl2PSString`. By default `Invoke-Curl2PS` outputs as a splat.
- Support for version specific parameter transformations ([#16](./../../issues/16))
- Support for `-F` and `--form` for PowerShell 7+ ([#30](./../../issues/30))

### 0.1.2

- Now supports commands that use `curl.exe`. (thank you [@ImportTaste](https://github.com/ImportTaste))

### 0.1.1

- Hugely improved parameter parsing to support both types of quotes in the same curl command ([#36](./../../issues/36))
- Added the `-CompressJSON` parameter which attempts to compress the JSON body.
- Added new curl parameters ([#35](./../../issues/35)):
  - `-k` and `--insecure`
  - `-s` and `--silent`
- Added support for grouped, single char parameters such as `-ksX` ([#35](./../../issues/35))

### 0.1.0 

- Added -u Curl parameter (thank you [@mavaddat!](https://github.com/mavaddat))
- Included Javascript to scrape curl parameters from the manpage (thank you [@mavaddat!](https://github.com/mavaddat))
- Changed `ConvertTo-IRM`'s `-String` parameter to `-CommandAsString`.
- Added `[OutputType]` to all commands.
- Updated docs.

### Other Credits

- Implemented classes and class based pester testing (thank you [@Stephanevg](https://github.com/Stephanevg))