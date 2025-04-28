Function ConvertTo-Curl2PSString {
    [OutputType([string])]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [PSObject]$Parameter
    )
    Begin {
        $baseStr = "Invoke-RestMethod -Uri '{URI}' -Method {METHOD}"
        $hts = @{}
    }
    Process {
        switch ($Parameter.Type) {
            'String' {
                if ($Parameter.ParameterName -eq 'Uri') {
                    $baseStr = $baseStr -replace '\{URI\}', $Parameter.Value
                } elseif ($Parameter.ParameterName -eq 'Method') {
                    $baseStr = $baseStr -replace '\{METHOD\}', $Parameter.Value
                } else {
                    $baseStr += " -$($Parameter.ParameterName) '$($Parameter.Value)'"
                }
            }
            'Hashtable' {
                if ($hts.Keys -notcontains $Parameter.ParameterName) {
                    $hts[$Parameter.ParameterName] = @{}
                }
                foreach ($key in $Parameter.Value.Keys) {
                    $hts[$Parameter.ParameterName][$key] = $Parameter.Value[$key]
                }
            }
            'Switch' {
                $baseStr += " -$($Parameter.ParameterName):`$$($Parameter.Value.ToString().ToLower())"
            }
            'PSCredential' {
                $cred = $paramGroup.Group[0].Value
                if ($cred.GetNetworkCredential().Password.Length -gt 0) {
                    Write-Warning 'This output possibly includes a plaintext password, please treat this securely.'
                    $authStr = "`$cred = [PSCredential]::new('$($cred.UserName)', (ConvertTo-SecureString '$($cred.GetNetworkCredential().Password)' -AsPlainText -Force))`n"
                } else {
                    "`$cred = Get-Credential -UserName '$($cred.UserName)' -Message 'Please input the password for user $($cred.UserName)'`n"
                }
                $baseStr = $authStr + $baseStr + " -Credential `$cred"
            }
            default {
                $baseStr += " -$($Parameter.ParameterName) $($Parameter.Value)"
            }
        }
    }
    End {
        foreach ($key in $hts.Keys) {
            $baseStr += "-$($key) $(ConvertTo-HashtableString $hts[$key] -IsForm:($key -eq 'Form'))"
        }
        $baseStr
    }
}