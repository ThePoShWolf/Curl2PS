Describe 'Invoke-Curl2PS' {
    Describe "Simple curl: 'curl https://theposhwolf.com'" {
        BeforeAll {
            $curlString = 'curl https://theposhwolf.com'
            $ht = Invoke-Curl2PS -CurlString $curlString
        }
        It 'outputs as a hashtable' {
            $ht | Should -Be 'System.Collections.Hashtable'
        }
        It 'contains both a Method and a Uri' {
            $ht.Keys | Should -Contain 'Method'
            $ht.Keys | Should -Contain 'Uri'
        }
        It 'the method is Get' {
            $ht['Method'] | Should -BeExactly 'Get'
        }
        It 'the Uri is https://theposhwolf.com' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
    }

    Describe "Simple curl with .exe: 'curl.exe https://theposhwolf.com" {
        BeforeAll {
            $curlString = 'curl.exe https://theposhwolf.com'
            $ht = Invoke-Curl2PS -CurlString $curlString
        }
        It 'outputs as a hashtable' {
            $ht | Should -Be 'System.Collections.Hashtable'
        }
        It 'contains both a Method and a Uri' {
            $ht.Keys | Should -Contain 'Method'
            $ht.Keys | Should -Contain 'Uri'
        }
        It 'the method is Get' {
            $ht['Method'] | Should -BeExactly 'Get'
        }
        It 'the Uri is https://theposhwolf.com' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
    }

    Describe 'Header curl: curl -H "X-Auth-Key: authKey" -H "X-Auth-Workspace: authWorkspace" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X POST https://theposhwolf.com' {
        BeforeAll {
            $curlString = 'curl -H "X-Auth-Key: authKey" -H "X-Auth-Workspace: authWorkspace" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X POST https://theposhwolf.com'
            $expectedHeaders = @{
                'X-Auth-Key'       = 'authKey'
                'X-Auth-Workspace' = 'authWorkspace'
                'X-Auth-Signature' = ''
                'Accept'           = 'application/json'
            }
            $ht = Invoke-Curl2PS -CurlString $curlString
        }
        It 'has the expected uri' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
        It 'has the expected method' {
            $ht['Method'] | Should -BeExactly 'POST'
        }
        It 'outputs as a hashtable' {
            $ht | Should -Be 'System.Collections.Hashtable'
        }
        It 'contains Method, Uri, and Headers' {
            $ht.Keys | Should -Contain 'Method'
            $ht.Keys | Should -Contain 'Uri'
            $ht.Keys | Should -Contain 'Headers'
        }
        It 'has the expected headers' {
            foreach ($key in $expectedHeaders.Keys) {
                $ht['Headers'].Keys | Should -Contain $key
            }
        }
        It 'has a ContentType parameter' {
            if ($PSVersionTable.PSVersion -gt [version]'7.0.0') {
                $ht.Keys | Should -Contain 'ContentType'
            } else {
                $ht['Headers'].Keys | Should -Contain 'Content-Type'
            }
        }
        It 'has headers with expected values' {
            foreach ($key in $expectedHeaders.Keys) {
                $ht['Headers'][$key] | Should -BeExactly $expectedHeaders[$key]
            }
        }
    }

    Describe "Data curl: curl -d '{ `"drink`": `"coffee`" }' --header `"Content-Type: application/json`" --header `"Accept: application/json`" https://theposhwolf.com" {
        BeforeAll {
            $curlString = "curl -d '{ `"drink`": `"coffee`" }' --header `"Content-Type: application/json`" --header `"Accept: application/json`" --request POST https://theposhwolf.com"
            $expectedHeaders = @{
                'Accept' = 'application/json'
            }
            $expectedBody = '{ "drink": "coffee" }'
            $ht = Invoke-Curl2PS -CurlString $curlString
        }
        It 'has the expected uri' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
        It 'has the expected method' {
            $ht['Method'] | Should -BeExactly 'POST'
        }
        It 'has the expected body' {
            $ht['Body'] | Should -BeExactly $expectedBody
        }
    }

    Describe 'User curl: curl -u "user:password" https://theposhwolf.com' {
        BeforeAll {
            $curlString = 'curl -u "user:password" https://theposhwolf.com'
            $credential = [pscredential]::new('user', (ConvertTo-SecureString 'password' -AsPlainText -Force))
            $ht = Invoke-Curl2PS -CurlString $curlString
        }
        It 'has the expected uri' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
        It 'has the expected method' {
            $ht['Method'] | Should -BeExactly 'Get'
        }
        It 'has the expected user format' {
            if ($PSVersionTable.PSVersion -gt [version]'7.0') {
                $ht.Keys | Should -Contain 'Credential'
                $ht.Keys | Should -Contain 'Authentication'

                $ht['Credential'].UserName | Should -BeExactly 'user'
                $ht['Credential'].GetNetworkCredential().Password | Should -BeExactly 'password'

                $ht['Authentication'] | Should -BeExactly 'Basic'
            } else {
                $ht.Keys | Should -Contain 'Headers'
                $ht['Headers'].Keys | Should -Contain 'Authorization'
                $ht['Headers']['Authorization'] | Should -BeExactly 'Basic dXNlcjpwYXNzd29yZA=='
            }
        }
    }

    Describe 'User curl 2: curl https://user:password@theposhwolf.com' {
        BeforeAll {
            $curlString = 'curl https://user:password@theposhwolf.com'
            $credential = [pscredential]::new('user', (ConvertTo-SecureString 'password' -AsPlainText -Force))
            $ht = Invoke-Curl2PS -CurlString $curlString
        }
        It 'has the expected uri' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
        It 'has the expected method' {
            $ht['Method'] | Should -BeExactly 'Get'
        }
        It 'has the expected user format' {
            if ($PSVersionTable.PSVersion -gt [version]'7.0') {
                $ht.Keys | Should -Contain 'Credential'
                $ht.Keys | Should -Contain 'Authentication'

                $ht['Credential'].UserName | Should -BeExactly 'user'
                $ht['Credential'].GetNetworkCredential().Password | Should -BeExactly 'password'

                $ht['Authentication'] | Should -BeExactly 'Basic'
            } else {
                $ht.Keys | Should -Contain 'Headers'
                $ht['Headers'].Keys | Should -Contain 'Authorization'
                $ht['Headers']['Authorization'] | Should -BeExactly 'Basic dXNlcjpwYXNzd29yZA=='
            }
        }
    }

    Describe 'Form curl: curl -F "filename=@./README.md" -F ''options={"application":"2","timeout":"500","priority":"0","profiles":["win7-sp1"],"analysistype":"1","force":"true","prefetch":"0", "properties":{"application_context":{"file_name":"xyz.pdf"}}}'' -X POST https://theposhwolf.com' {
        BeforeAll {
            $curlString = @'
curl -F "filename=@./README.md" -F 'options={"application":"2","timeout":"500","priority":"0","profiles":["win7-sp1"],"analysistype":"1","force":"true","prefetch":"0", "properties":{"application_context":{"file_name":"xyz.pdf"}}}' -X POST https://theposhwolf.com
'@
            $ht = Invoke-Curl2PS -CurlString $curlString
            $expectedForm = @{
                'filename' = Get-Item ./README.md
                'options'  = @{
                    'analysistype' = '1'
                    'application'  = '2'
                    'force'        = 'true'
                    'prefetch'     = '0'
                    'priority'     = '0'
                    'profiles'     = 'win7-sp1'
                    'properties'   = @{
                        'application_context' = @{
                            'file_name' = 'xyz.pdf'
                        }
                    }
                    'timeout'      = '500'
                }
            }
        }
        It 'has the expected uri' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
        It 'has the expected method' {
            $ht['Method'] | Should -BeExactly 'POST'
        }
        It 'has the expected form data' {
            if ($PSVersionTable.PSVersion -gt [version]'7.0') {
                $ht.Keys | Should -Contain 'Form'
                $ht['Form']['filename'] | Should -BeOfType [System.IO.FileInfo]
                $ht['Form']['filename'].FullName | Should -Be $expectedForm['filename'].FullName
                foreach ($key in $expectedForm['options'].Keys) {
                    $ht['Form']['options'].Keys | Should -Contain $key
                    if ($expectedForm['options'][$key] -isnot [hashtable]) {
                        $ht['Form']['options'][$key] | Should -Be $expectedForm['options'][$key]
                    }
                }
                $ht['Form']['options'].Keys | Should -Contain 'properties'
                $ht['Form']['options']['properties'].Keys | Should -Contain 'application_context'
                $ht['Form']['options']['properties']['application_context'].Keys | Should -Contain 'file_name'
                $ht['Form']['options']['properties']['application_context']['file_name'] | Should -Be 'xyz.pdf'
            } else {
                Write-Warning 'Curl2PS does not support -F / --form conversion for PowerShell versions less than 7.0.'
            }
        }
    }
    Describe "--data-raw curl: curl --data-raw '{ `"drink`": `"coffee`" }' -H 'Content-Type: application/json' -H 'Accept: application/json' https://theposhwolf.com" {
        Context "--data-raw curl batch requests to Microsoft Graph" {
            It "Parses a complex cURL string with --data-raw correctly" {
                $CurlString = @"
curl 'https://graph.microsoft.com/beta/`$batch' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,da;q=0.8' \
  -H 'authorization: REMOVED' \
  -H 'client-request-id: REMOVED' \
  -H 'content-type: application/json' \
  -H 'dnt: 1' \
  -H 'origin: https://sandbox-1.reactblade.portal.azure.net' \
  -H 'priority: u=1, i' \
  -H 'referer: https://sandbox-1.reactblade.portal.azure.net/' \
  -H 'sec-ch-ua: "Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: cross-site' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36' \
  -H 'x-ms-client-request-id: REMOVED' \
  -H 'x-ms-client-session-id: REMOVED' \
  -H 'x-ms-command-name: Common - AutoBatch' \
  --data-raw '{"requests":[{"id":"1","method":"GET","url":"/users/REMOVED/rolemanagement/directory/transitiveRoleAssignments/`$count","headers":{"ConsistencyLevel":"eventual","Accept":"text/plain","x-ms-command-name":"UserManagement - UserOverviewCounts","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED"}},{"id":"2","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/basic/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/identities/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/inviteGuest"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/disable"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/enable"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/convertExternalToInternalMemberUser"},{"directoryScopeId":"/","resourceAction":"microsoft.people/users/photo/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/parentalControls/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/assignLicense"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/contactInfo/update"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"3","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/jobInfo/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/applications/extensionProperties/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/manager/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/password/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/sponsors/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/usageLocation/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/userPrincipalName/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/users/userType/update"},{"directoryScopeId":"/","resourceAction":"microsoft.directory/auditLogs/standard/read"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/basic/update"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"4","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/identities/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/inviteGuest"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/disable"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/enable"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/convertExternalToInternalMemberUser"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.people/users/photo/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/parentalControls/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/assignLicense"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/contactInfo/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/jobInfo/update"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"5","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/applications/extensionProperties/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/manager/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/password/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/sponsors/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/usageLocation/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/userPrincipalName/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/userType/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/auditLogs/standard/read"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"6","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/auditLogs/standard/read"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"7","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/invalidateAllRefreshTokens"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/password/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/delete"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"8","method":"GET","url":"/users/REMOVED?`$select=isManagementRestricted","headers":{"x-ms-command-name":"UserManagement - UserProfileInfoHook","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED"}},{"id":"9","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/enable"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/disable"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/parentalControls/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/basic/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/assignLicense"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/contactInfo/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/jobInfo/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/applications/extensionProperties/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/identities/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/manager/update"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"10","method":"POST","url":"/roleManagement/directory/estimateAccess","body":{"resourceActionAuthorizationChecks":[{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/password/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/sponsors/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/usageLocation/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/userPrincipalName/update"},{"directoryScopeId":"/REMOVED","resourceAction":"microsoft.directory/users/userType/update"}]},"headers":{"x-ms-command-name":"RBACv2 - estimateAccess","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED","Content-Type":"application/json"}},{"id":"11","method":"GET","url":"/riskyUsers/REMOVED","headers":{"x-ms-command-name":"UserManagement - GetRiskyUserStatus","x-ms-client-request-id":"REMOVED","client-request-id":"REMOVED","x-ms-client-session-id":"REMOVED"}}]}'
"@

                $splat = Invoke-Curl2PS $CurlString
                $splat.Uri | Should -Be "https://graph.microsoft.com/beta/`$batch"

                # Validate the parsed splat object
                $splat | Should -Not -BeNullOrEmpty
                $requests = $splat.Body | ConvertFrom-Json | Select-Object -ExpandProperty requests -ErrorAction Stop
                $requests | Should -Not -BeNullOrEmpty

                # Validate first request
                $requests[0].id | Should -Be "1"
                $requests[0].method | Should -Be "GET"
                $requests[0].url | Should -Be "/users/REMOVED/rolemanagement/directory/transitiveRoleAssignments/```$count"
                $requests[0].headers.ConsistencyLevel | Should -Be "eventual"
                $requests[0].headers.Accept | Should -Be "text/plain"
                # Validate the second request
                $requests[1].id | Should -Be "2"
                $requests[1].method | Should -Be "POST"
                $requests[1].url | Should -Be "/roleManagement/directory/estimateAccess"
                $requests[1].headers.'x-ms-command-name' | Should -Be "RBACv2 - estimateAccess"
                $requests[1].headers.'Content-Type' | Should -Be "application/json"
                $requests[1].body.resourceActionAuthorizationChecks[0].directoryScopeId | Should -Be "/"
                $requests[1].body.resourceActionAuthorizationChecks[0].resourceAction | Should -Be "microsoft.directory/users/basic/update"
            }
        }

        Context "--data-raw curl hitting Microsoft Graph test endpoint" {
            It "Parses a simple cURL string and invokes the endpoint" {
                $CurlString = @"
curl 'https://graph.office.net/en-us/graph/api/proxy?url=https%3A%2F%2Fgraph.microsoft.com%2Fv1.0%2Fme' \
  -H 'accept: */*' \
  -H 'accept-language: en-US,en;q=0.9,da;q=0.8' \
  -H 'authorization: Bearer {token:https://graph.microsoft.com/}' \
  -H 'content-type: application/json' \
  -H 'dnt: 1' \
  -H 'origin: https://developer.microsoft.com' \
  -H 'prefer: ms-graph-dev-mode' \
  -H 'priority: u=1, i' \
  -H 'referer: https://developer.microsoft.com/' \
  -H 'sdkversion: GraphExplorer/4.0' \
  -H 'sec-ch-ua: "Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: cross-site' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
"@

                $splat = Invoke-Curl2PS $CurlString

                # Validate the parsed splat object
                $splat | Should -Not -BeNullOrEmpty
                $splat.Uri | Should -Be "https://graph.office.net/en-us/graph/api/proxy?url=https%3A%2F%2Fgraph.microsoft.com%2Fv1.0%2Fme"
                $splat.Method | Should -Be "Get"
                $splat.Headers["accept"] | Should -Be "*/*"
                $rest = invoke-restmethod @splat -ErrorAction Stop
                $rest | Should -Not -BeNullOrEmpty
            }
        }
    }

}