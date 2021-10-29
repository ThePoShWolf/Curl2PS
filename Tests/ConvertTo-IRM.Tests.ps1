
#. "$PSScriptRoot\..\src\public\ConvertTo-IRM.ps1"

describe "Testing ConvertTo-IRM"{

    $TestCase1 = @{}
    $TestCase1.CURL = 'curl -X GET https://PlopServer/identity/api/tenants/Woo/subtenants -H "Accept: application/json" -H "Authorization: Bearer {{token}}"'
    $TestCase1.IRME = "Invoke-RestMethod -Uri 'https://plopserver/identity/api/tenants/Woo/subtenants' -Method GET -Verbose:`$false -Headers @{`n    'Authorization' = 'Bearer {{token}}'`n    'Accept' = 'application/json'`n}"
    
    $TestCase2 = @{}
    $TestCase2.CURL = 'curl -X GET "https://testdomain.com/catalog-service/api/consumer/entitledCatalogItems?page=1&limit=1000" -H "Accept: application/json" -H "Authorization: Bearer {{token}}"'
    $TestCase2.IRME = "Invoke-RestMethod -Uri 'https://testdomain.com/catalog-service/api/consumer/entitledCatalogItems?page=1&limit=1000' -Method GET -Verbose:`$false -Headers @{`n    'Authorization' = 'Bearer {{token}}'`n    'Accept' = 'application/json'`n}"

    $TestCases = @($TestCase1,$TestCase2)

    Context "Correct URL cases" {
        IT 'When passed a correct CURL command, it should return correct Invoke-RestMethod'{
            Param(
                $CURL,$IRME
            )

            ConvertTo-IRM -CurlCommand $CURL -GetParamsAsString | Should be $IRME

        } -TestCases $TestCases

    }
    Context "Incorect URL Cases"{
        It "Incorrect URL should not be converted" {

            $Url = "curl -X GET 'https://////plop' -H 'Accept: application/json' -H 'Authorization: Bearer {{token}}'"  
            #What to do in this case? 
        } -Skip
          
    }
}

<#



 

#>
