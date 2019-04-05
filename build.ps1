[cmdletbinding()]
param(
    [string[]]$Task = 'ModuleBuild'
)

$DependentModules = @('PSDeploy','InvokeBuild','PlatyPS','Pester') # add pester when pester tests are added
Foreach ($Module in $DependentModules){
    If (-not (Get-Module $module -ListAvailable)){
        Install-Module -name $Module -Scope CurrentUser -Force
    }
    Import-Module $module -ErrorAction Stop
}
# Builds the module by invoking InvokeBuild
Invoke-Build "$PSScriptRoot\Curl2PS.build.ps1" -Task $Task