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

}