# Curl2PS

[![Curl2PS](https://img.shields.io/powershellgallery/v/Curl2PS.svg?style=flat-square&label=Curl2PS "Curl2PS")](https://www.powershellgallery.com/packages/Curl2PS/)

This module is a utility module to help convert cURL commands to Invoke-RestMethod syntax.

Using `Invoke-Curl2PS` this module is designed to convert a cURL command to either a splat or the string representation for use with `Invoke-RestMethod`.

To install the module:

```powershell
# PowerShellGet
Install-Module Curl2PS

# PSResourceGet
Install-PSResource Curl2PS
```

Usage examples:

```powershell
$CurlString = @"
curl -H "X-Auth-Key: authKey" -H "X-Auth-Workspace: authWorkspace" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://theposhwolf.com/api/v1/demo
"@

$splat = Invoke-Curl2PS $CurlString
Invoke-RestMethod @splat
```

Or if you'd prefer the string command:

```powershell
Invoke-Curl2PS $CurlString -AsString
```

Output:

```powershell
Invoke-RestMethod -Uri https://theposhwolf.com/api/v1/demo -Method GET -Headers @{
    'X-Auth-Key' = 'authKey'
    'Accept' = 'application/json'
    'X-Auth-Signature' = ''
    'X-Auth-Workspace' = 'authWorkspace'
    'Content-Type' = 'application/json'
}
```

Or another example:

```powershell
Invoke-Curl2PS -CurlString 'curl --request GET "https://user:password@theposhwolf.com/api/v1/demo?key=value"  --data ""' -AsString
```

Output:

```powershell
Invoke-RestMethod -Uri 'https://theposhwolf.com/api/v1/demo' -Method GET -Headers @{
    'Authorization' = 'Basic dXNlcjpwYXNzd29yZA=='
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
  - Parameter specific conversions are stored in a dedicated [config.ps1](./src/config.ps1) file with each conversion declared as a scriptblock.
  - `Invoke-Curl2PS` introduces a more PowerShelly approach that outputs an array of Curl2PSParameterDefinition objects that can be piped to `ConvertTo-Curl2PSSplat` and `ConvertTo-Curl2PSString`. By default `Invoke-Curl2PS` outputs as a splat.
- Support for version specific parameter transformations ([#16](./../../issues/16)) through a `MinimumVersion` property in [config.ps1](./src/config.ps1).
- Support for `-F` and `--form` for PowerShell 7+ ([#30](./../../issues/30))
- Added more extensive Pester tests.

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