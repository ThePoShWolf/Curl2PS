InModuleScope -ModuleName Curl2PS{
    Describe '[URL]-[Constructors]' {

        It '[URL]-[Constructor]([string]urlString) should Not Throw' {

            # -- Arrange


            [string]$urlString = 'https://us1.pdfgeneratorapi.com/api/v3/templates'

            # -- Act

            # -- Assert

            { [URL]::New($urlString) } | Should Not Throw 

        }# end of it block


    }# end of Describe block
    Describe '[URL]-[Methods]' {

        #Public Method
        It '[URL] --> ToString() : [string] - should Not Throw' {

            # -- Arrange

            # -- Act

            $Instance = [URL]::New($urlString)

            # -- Assert

            { $Instance.ToString() } | Should Not Throw

        } #End It Block

        #Public Method
        It '[URL] --> ToString() : [string] - should return type [string]' {

            # -- Arrange

            # -- Act

            $Instance = [URL]::New($urlString)
            # -- Assert

            ($Instance.ToString()).GetType().Name | Should be string

        } #End It Block

    }#EndDescribeBlock
}