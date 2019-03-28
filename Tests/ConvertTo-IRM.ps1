
 . "$PSScriptRoot\..\src\public\ConvertTo-IRM.ps1"

describe "Testin ConvertTo-IRM"{

    $TestCase1 = @{}
    $TestCase1.CURL = "curl -X GET https://PlopServer/identity/api/tenants/Woo/subtenants -H 'Accept: application/json' -H 'Authorization: Bearer {{token}}'"
    $TestCase1.IRME = @"
Invoke-RestMethod -Method GET https://PlopServer/identity/api/tenants/Woo/subtenants -Headers ('{"Accept":"application/json","Authorization":"Bearer {{token}}"}' | ConvertFrom-Json)
"@
    
    $TestCase2 = @{}
    $TestCase2.CURL ="curl -X GET 'https://{{vRA-FQDN}}/catalog-service/api/consumer/entitledCatalogItems?page=1&limit=1000' -H 'Accept: application/json' -H 'Authorization: Bearer {{token}}'"
    $TestCase2.IRME = @"
Invoke-RestMethod -Method GET 'https://{{vRA-FQDN}}/catalog-service/api/consumer/entitledCatalogItems?page=1&limit=1000' -Headers ('{"Accept":"application/json","Authorization":"Bearer {{token}}"}' | ConvertFrom-Json)
"@

$TestCases = @($TestCase1,$TestCase2)

    Context "Correct URL cases" {
        IT 'When passed correct CURL command it should return correct invoke-restmethod'{
            Param(
                $CURL,$IRME
            )

            ConvertTo-IRM -CurlString $CURL | Should be $IRME

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
