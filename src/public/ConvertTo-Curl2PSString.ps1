Function ConvertTo-Curl2PSString {
    [OutputType([string])]
    param (
        [Curl2PSParameterDefinition[]]$Parameters
    )
    $baseStr = "Invoke-RestMethod -Uri '$($splat.Uri)' -Method $($splat.Method)"
    foreach ($paramGroup in $parameters | Group-Object ParameterName) {
        if ($('Uri', 'Method') -contains $paramGroup.Name) {
            continue
        }
        if ($paramGroup.Count -gt 1) {
            if ($paramGroup[0].Group[0].Type -eq 'Hashtable') {
                $ht = @{}
                foreach ($pg in $paramGroup.Group) {
                    foreach ($key in $pg.Value.Keys) {
                        $ht[$key] = $pg.Value[$key]
                    }
                }
                $baseStr += " -$($paramGroup.Name) $(ConvertTo-HashtableString $ht)"
            } else {
                Write-Warning "Multiple values for parameter $($paramGroup.Name) of type $($paramGroup.Group[0].TypeNames) are not supported."
            }
        } elseif ($paramGroup[0].Group[0].Type -eq 'Hashtable') {
            $baseStr += " -$($paramGroup.Name) $(ConvertTo-HashtableString $paramGroup.Group[0].Value)"
        } elseif ($paramGroup[0].Group[0].Type -eq 'Switch') {
            $baseStr += " -$($paramGroup.Name):`$$($paramGroup.Group[0].Value.ToString().ToLower())"
        } elseif ($paramGroup[0].Group[0].Type -eq 'String') {
            $baseStr += " -$($paramGroup.Name) '$($paramGroup.Group[0].Value)'"
        } elseif ($paramGroup[0].Group[0].Type -eq 'PSCredential') {
            $cred = $paramGroup.Group[0].Value
            if ($cred.GetNetworkCredential().Password.Length -gt 0) {
                Write-Warning 'This output possibly includes a plaintext password, please treat this securely.'
                $authStr = "`$cred = [PSCredential]::new('$($cred.UserName)', (ConvertTo-SecureString '$($cred.GetNetworkCredential().Password)' -AsPlainText -Force))`n"
            } else {
                "`$cred = Get-Credential -UserName '$($cred.UserName)' -Message 'Please input the password for user $($cred.UserName)'`n"
            }
            $baseStr = $authStr + $baseStr + " -Credential `$cred"
        } else {
            $baseStr += " -$($paramGroup.Name) $($paramGroup.Group[0].Value)"
        }
    }
    $baseStr
}