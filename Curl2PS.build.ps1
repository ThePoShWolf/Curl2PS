$srcPath = "$PSScriptRoot\src"
$buildPath = "$PSScriptRoot\build"
$docPath = "$PSScriptRoot\docs"
$testPath = "$PSScriptRoot\tests"
$moduleName = ($MyInvocation.MyCommand.Name.Split('.') | Select-Object -SkipLast 2) -join '.'
$modulePath = "$buildPath\$ModuleName"
$version = '0.0.3'



# Clean out any previous builds
task Clean {
    if (Get-Module $moduleName) {
        Remove-Module $moduleName
    }
    if (Test-Path $modulePath) {
        Remove-Item $modulePath -Recurse -ErrorAction Ignore | Out-Null
    }
}

# Build the docs, depends on PlatyPS
task DocBuild ModuleBuild, {
    if (-not (Test-Path $docPath)) {
        New-Item $docPath -ItemType Directory
    }
    New-ExternalHelp $docPath -OutputPath "$modulePath\EN-US"
}

# Build the module
task ModuleBuild Clean, {
    $moduleScriptFiles = Get-ChildItem $srcPath -Filter *.ps1 -File -Recurse
    if (-not(Test-Path $modulePath)) {
        New-Item $modulePath -ItemType Directory
    }

    # Add using.ps1 to the .psm1 first
    foreach ($file in $moduleScriptFiles | ?{$_.Name -eq 'using.ps1'}) {
        if ($file.fullname) {
            Copy-Item $file.FullName -Destination $modulePath
        }
    }

    # Add all .ps1 files to the .psm1
    foreach ($file in $moduleScriptFiles | ?{$_.Name -ne 'onload.ps1' -and $_.Name -ne 'using.ps1'}) {
        if ($file.fullname) {
            Get-Content $file.fullname | Out-File "$modulePath\$moduleName.psm1" -Append -Encoding utf8
        }
    }
    
    # Add the onload.ps1 files last
    foreach ($file in $moduleScriptFiles | ?{$_.Name -eq 'onload.ps1'}) {
        if ($file.fullname) {
            Get-Content $file.fullname | Out-File "$modulePath\$moduleName.psm1" -Append -Encoding utf8
        }
    }

    # Copy dll dependencies
    if (-not (Test-Path $modulePath\dependencies)) {
        New-Item "$modulePath\dependencies" -ItemType Directory
    }
    foreach ($dll in (Get-ChildItem $srcPath\dependencies -filter *.dll -File)) {
        Copy-Item $dll.FullName -Destination $modulePath\dependencies
    }

    # Copy the manifest
    Copy-Item "$srcPath\$moduleName.psd1" -Destination $modulePath

    $moduleManifestData = @{
        Path = "$modulePath\$moduleName.psd1"
        # Only export the public files
        FunctionsToExport = ($moduleScriptFiles | Where-Object {$_.FullName -match "\\public\\[^\.]+\.ps1$"}).basename
        ModuleVersion = $version
    }
    Update-ModuleManifest @moduleManifestData
}

Task Test ModuleBuild, {
    Import-Module $modulePath -RequiredVersion $version
    Invoke-Pester $testPath
}

task Publish Test, DocBuild, {
    Invoke-PSDeploy -Force
}

task All ModuleBuild, Publish