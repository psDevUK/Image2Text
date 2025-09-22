<#
.SYNOPSIS
Converts images to ASCII art with optional color rendering and file export.

.DESCRIPTION
This module provides a high-performance wrapper around a .NET-based image-to-text converter. It transforms raster images into terminal-friendly ASCII representations, with support for:

- True-color ANSI output for rich console rendering
- Aspect ratio correction and gamma tuning
- File export with automatic plain-text formatting
- Parameter sets to enforce safe and predictable usage

Designed for PowerShell 6 and 7+, it supports creative automation, terminal art, and comic-style branding workflows.

.PARAMETER ImagePath
Path to the input image file (e.g., PNG, JPG, BMP).

.PARAMETER Width
Target width in characters for the ASCII output. Height is auto-calculated based on image dimensions and aspect ratio.

.PARAMETER AspectRatio
Aspect ratio correction factor to compensate for character height distortion in terminal fonts. Default is 0.55.

.PARAMETER Gamma
Gamma correction factor to adjust perceived brightness. Default is 2.2.

.PARAMETER UseColor
Switch to enable true-color ANSI output for console rendering. Only available in the 'Console' parameter set.

.PARAMETER SaveToFile
Path to save the ASCII output as a plain-text file. Automatically strips ANSI codes. Only available in the 'File' parameter set.

.PARAMETER InvertColor
Switch to invert image colors before conversion. Only available in the 'File' parameter set. This uses MS Paint to perform the inversion.

.EXAMPLE
Convert-Image2Text -ImagePath "C:\Images\logo.png" -Width 150 -UseColor

.EXAMPLE
Convert-Image2Text -ImagePath "C:\Images\logo.png" -Width 150 -SaveToFile "C:\Output\logo.txt"

.EXAMPLE
Convert-Image2Text -ImagePath "C:\Images\logo.png" -Width 400 -SaveToFile "C:\Output\logo.txt" -InvertColor

.NOTES
Author: Adam B.
Module: Image2Text
Version: 1.0.0
License: MIT
#>

# Load the compiled .NET assembly vital to this module's functionality
$assemblyPath = Join-Path $PSScriptRoot 'Image2Text.dll'
if (-not (Test-Path $assemblyPath)) {
    throw "Required assembly not found: $assemblyPath"
}
Add-Type -Path $assemblyPath

function Convert-Image2Text {
    [CmdletBinding(DefaultParameterSetName = 'Console')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Console')]
        [Parameter(Mandatory, ParameterSetName = 'File')]
        [string]$ImagePath,

        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'File')]
        [int]$Width = 100,

        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'File')]
        [double]$AspectRatio = 0.55,

        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'File')]
        [double]$Gamma = 2.2,

        [Parameter(ParameterSetName = 'Console')]
        [switch]$UseColor,

        [Parameter(Mandatory, ParameterSetName = 'File')]
        [string]$SaveToFile,

        [Parameter(ParameterSetName = 'File')]
        [switch]$InvertColor

    )

    try {
        if (-not (Test-Path $ImagePath)) {
            throw "Image file not found: '$ImagePath'"
        }

        $useColorFlag = $UseColor.IsPresent
        $lines = [Image2Text.AsciiConverter]::Convert($ImagePath, $Width, $AspectRatio, $Gamma, $useColorFlag)

        if ($PSCmdlet.ParameterSetName -eq 'File') {
            if ($PSCmdlet.ParameterSetName -eq 'File') {
                # Always strip ANSI codes for file output
                $lines = $lines | ForEach-Object { $_ -replace "\u001b\[[0-9;]*m", "" }
            }

            $parentFolder = Split-Path $SaveToFile -Parent
            if (-not (Test-Path $parentFolder)) {
                throw "SaveToFile path is invalid or the folder does not exist: '$parentFolder'"
            }

            if ($InvertColor.IsPresent) {
                $tempPath = Join-Path $env:TEMP ("inverted_" + [System.IO.Path]::GetFileName($ImagePath))
                Copy-Item $ImagePath $tempPath -Force
                Write-Host "Inverting image colors via MS Paint..."

                # Launch Paint
                Start-Process "mspaint.exe" -ArgumentList "`"$tempPath`""
                Start-Sleep -Seconds 2  # Give Paint time to open

                # Create VBScript to send keys
                $vbs = @"
Set WshShell = WScript.CreateObject("WScript.Shell")
WScript.Sleep 1000
WshShell.SendKeys "^a"
WScript.Sleep 500
WshShell.SendKeys "^+i"
WScript.Sleep 500
WshShell.SendKeys "^s"
WScript.Sleep 500
WshShell.SendKeys "%{F4}"
"@

                $vbsPath = Join-Path $env:TEMP "invertPaint.vbs"
                Set-Content -Path $vbsPath -Value $vbs -Encoding ASCII

                # Run the VBScript
                Start-Process "wscript.exe" -ArgumentList "`"$vbsPath`"" -WindowStyle Hidden

                Start-Sleep -Seconds 3  # Wait for Paint to close and save

                # Use the inverted image
                $ImagePath = $tempPath
            }



            try {
                [System.IO.File]::WriteAllLines($SaveToFile, $lines)
                Write-Host "ASCII output saved to: $SaveToFile"
            } catch {
                throw "Failed to write to file: '$SaveToFile'. Check permissions."
            }
        } else {
            $lines
        }
    } catch {
        Write-Error $_
    }
}
