if ($PSVersionTable.PSVersion.Major -lt 6) {
    $dlls2Load = @(
        'System.Collections.Immutable.dll'
        'System.Reflection.Metadata.dll'
        'Microsoft.CodeAnalysis.dll'
        'Microsoft.CodeAnalysis.CSharp.dll'
    )
    foreach ($dll in $dlls2Load){
        Add-Type -Path "$PSScriptRoot\dependencies\$dll"
    }
}