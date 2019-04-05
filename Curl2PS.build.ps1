$srcPath = "$PSScriptRoot\src"
$buildPath = "$PSScriptRoot\build"
$docPath = "$PSScriptRoot\docs"
$testPath = "$PSScriptRoot\tests"
$moduleName = "Curl2PS"
$modulePath = "$buildPath\$moduleName"
$author = 'Anthony Howell'
$version = '0.0.1'

task Clean {
    If(Get-Module $moduleName){
        Remove-Module $moduleName
    }
    If(Test-Path $modulePath){
        $null = Remove-Item $modulePath -Recurse -ErrorAction Ignore
    }
}

task DocBuild {
    New-ExternalHelp $docPath -OutputPath "$modulePath\EN-US"
}

task ModuleBuild Clean, DocBuild, {
    $pubFiles = Get-ChildItem "$srcPath\public" -Filter *.ps1 -File
    #$privFiles = Get-ChildItem "$srcPath\private" -Filter *.ps1 -File
    $classFiles = Get-ChildItem "$srcPath\classes" -Filter *.ps1 -File
    If(-not(Test-Path $modulePath)){
        New-Item $modulePath -ItemType Directory
    }
    ForEach($file in ($pubFiles + $privFiles + $classFiles)) {
        Get-Content $file.FullName | Out-File "$modulePath\$moduleName.psm1" -Append -Encoding utf8
    }
    Copy-Item "$srcPath\$moduleName.psd1" -Destination $modulePath

    $moduleManifestData = @{
        Author = $author
        Copyright = "(c) $((get-date).Year) $author. All rights reserved."
        Path = "$modulePath\$moduleName.psd1"
        FunctionsToExport = $pubFiles.BaseName
        RootModule = "$moduleName.psm1"
        ModuleVersion = $version
        ProjectUri = 'https://github.com/ThePoShWolf/Curl2PS'
    }
    Update-ModuleManifest @moduleManifestData
    Import-Module $modulePath -RequiredVersion $version
}

task Test ModuleBuild, {
    Invoke-Pester $testPath
}

task Publish Test, {
    Invoke-PSDeploy -Path $PSScriptRoot -Force
}

task All ModuleBuild, Publish