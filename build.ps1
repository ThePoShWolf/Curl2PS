[cmdletbinding()]
param(
    [string[]]$Task = 'ModuleBuild'
)

$DependentModules = @('PSDeploy', 'InvokeBuild', 'PlatyPS', 'Pester')
foreach ($Module in $DependentModules) {
    if (-not (Get-Module $module -ListAvailable)) {
        Install-Module -Name $Module -Scope CurrentUser -Force
    }
    if (-not (Get-Module $module)) {
        Import-Module $module -ErrorAction Stop
    }
}
# Builds the module by invoking InvokeBuild
Invoke-Build "$PSScriptRoot\Curl2PS.build.ps1" -Task $Task