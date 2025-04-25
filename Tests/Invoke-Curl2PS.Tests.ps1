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
            $ht.Keys | Should -BeExactly @('Method', 'Uri')
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
        It 'has the expected uri' {
            $ht['Uri'] | Should -BeExactly 'https://theposhwolf.com'
        }
        It 'has the expected method' {
            $ht['Method'] | Should -BeExactly 'POST'
        }
    }
}