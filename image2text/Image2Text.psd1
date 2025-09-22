@{
    # Module metadata
    RootModule         = 'Image2Text.psm1'
    ModuleVersion      = '1.0.4'
    GUID               = 'd3f9c5a2-7f3e-4c2f-9a1e-abc123456789'
    Author             = 'Adam B.'
    CompanyName        = 'PowerShellMagic'
    Description        = 'Converts images to ASCII art with optional color output and file export. Built for creative automation and terminal flair.'

    # Compatible with PowerShell 5.1 and 7+
    PowerShellVersion  = '7.0'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Functions to export
    FunctionsToExport  = @('Convert-Image2Text')

    # Cmdlets, aliases, variables
    CmdletsToExport    = @()
    AliasesToExport    = @()
    VariablesToExport  = @()

    # Required assemblies
    RequiredAssemblies = @('Image2Text.dll')

    # Private data (optional)
    PrivateData = @{
        PSData = @{
            Tags         = @('ASCII', 'Image', 'Color', 'Terminal', 'Art', 'Export')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/yourrepo/Image2Text'
            IconUri      = 'https://yourdomain.com/icon.png'
            ReleaseNotes = 'Added support for color output, file saving, and plain text export.'
        }
    }
}
