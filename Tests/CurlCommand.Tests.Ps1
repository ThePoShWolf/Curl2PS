InModuleScope -ModuleName Curl2PS {
    Describe '[CurlCommand]-[Constructors]' {

        It '[CurlCommand]-[Constructor]([string]curlString) should Not Throw' {

            # -- Arrange

            [string]$curlString = 'curl -H "X-Auth-Key: 61e5f04ca1794253ed17e6bb986c1702" -H "X-Auth-Workspace: demo.example@actualreports.com" -H "X-Auth-Signature: " -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://us1.pdfgeneratorapi.com/api/v3/templates'

            # -- Act

            # -- Assert

            { [CurlCommand]::New($curlString) } | Should -Not -Throw

        }# end of it block


    }# end of Describe block
    Describe '[CurlCommand]-[Methods]' {

        #Public Method
        It '[CurlCommand] --> ToString() : [string] - should Not Throw' {

            # -- Arrange

            # -- Act

            $Instance = [CurlCommand]::New($curlString)

            # -- Assert

            { $Instance.ToString() } | Should -Not -Throw

        } #End It Block

        #Public Method
        It '[CurlCommand] --> ToString() : [string] - should return type [string]' {

            # -- Arrange

            # -- Act

            $Instance = [CurlCommand]::New($curlString)
            # -- Assert

            ($Instance.ToString()).GetType().Name | Should -Be String

        } #End It Block

        #Public Method
        It '[CurlCommand] --> ToIRM() : [string] - should Not Throw' {

            # -- Arrange

            # -- Act

            $Instance = [CurlCommand]::New($curlString)

            # -- Assert

            { $Instance.ToIRM() } | Should -Not -Throw

        } #End It Block

        #Public Method
        It '[CurlCommand] --> ToIRM() : [string] - should return type [string]' {

            # -- Arrange

            # -- Act

            $Instance = [CurlCommand]::New($curlString)
            # -- Assert

            ($Instance.ToIRM()).GetType().Name | Should -Be String

        } #End It Block

    }#EndDescribeBlock

}