[cmdletbinding()]
param(
    [string[]]$Task = 'ModuleBuild'
)

$DependentModules = @('InvokeBuild', 'PlatyPS', 'Pester')
foreach ($Module in $DependentModules) {
    if (-not (Get-Module $module -ListAvailable)) {
        Write-Host "Installing '$module'..."
        Install-Module -Name $Module -Scope CurrentUser -Force
    }
    if (-not (Get-Module $module)) {
        Write-Host "Importing '$module'..."
        Import-Module $module -ErrorAction Stop
    }
}
# Builds the module by invoking InvokeBuild
Invoke-Build "$PSScriptRoot\Curl2PS.build.ps1" -Task $Task