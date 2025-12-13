#Requires -Version 5.1
<#
.SYNOPSIS
    Konvertiert SVG-Icons zu BMP und benennt sie nach UX.bmp Schema
.DESCRIPTION
    Konvertiert die SVG-Icons in BMP-Format (64x64) und benennt sie
    nach dem Eding CNC Schema: U1.bmp, U2.bmp, ..., U12.bmp
.NOTES
    Version: 1.0
    Benötigt: Windows PowerShell 5.1+ mit .NET Framework
#>

# ============================================================================
# KONFIGURATION
# ============================================================================

$ICON_SIZE = 64  # Größe in Pixel (64x64 für Eding CNC)

# Mapping: SVG-Dateiname -> BMP-Dateiname
$ICON_MAPPING = @{
    "user_1_tool_length.svg"        = "U1.bmp"
    "user_2_z_zero.svg"             = "U2.bmp"
    "user_3_spindle_warmup.svg"     = "U3.bmp"
    "user_4_tool_change.svg"        = "U4.bmp"
    "user_5_edge_probe.svg"         = "U5.bmp"
    "user_6_corner_rotation.svg"    = "U6.bmp"
    "user_7_hole_probe.svg"         = "U7.bmp"
    "user_8_cylinder_probe.svg"     = "U8.bmp"
    "user_9_break_check.svg"        = "U9.bmp"
    "user_10_rectangle_measure.svg" = "U10.bmp"
    "user_11_thickness_measure.svg" = "U11.bmp"
    "user_12_coordinate_manager.svg"= "U12.bmp"
}

# ============================================================================
# FUNKTIONEN
# ============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )

    switch ($Type) {
        "SUCCESS" { Write-Host "✓ $Message" -ForegroundColor Green }
        "ERROR"   { Write-Host "✗ $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "⚠ $Message" -ForegroundColor Yellow }
        "INFO"    { Write-Host "ℹ $Message" -ForegroundColor Cyan }
        default   { Write-Host $Message }
    }
}

function Show-Banner {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "║           SVG → BMP KONVERTER FÜR EDING CNC                   ║" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "║           Konvertiert Icons nach UX.bmp Schema                ║" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host ""
}

function Test-ImageMagick {
    try {
        $result = & magick --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
    } catch {
        try {
            $result = & convert --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
        } catch {
            return $false
        }
    }
    return $false
}

function Test-Inkscape {
    try {
        $result = & inkscape --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

function Convert-SVGtoBMP-ImageMagick {
    param(
        [string]$SourceSVG,
        [string]$TargetBMP,
        [int]$Size
    )

    try {
        # Versuche magick (ImageMagick 7+)
        & magick convert -background none -resize "${Size}x${Size}" "$SourceSVG" "$TargetBMP" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            return $true
        }

        # Versuche convert (ImageMagick 6)
        & convert -background none -resize "${Size}x${Size}" "$SourceSVG" "$TargetBMP" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            return $true
        }

        return $false
    } catch {
        return $false
    }
}

function Convert-SVGtoBMP-Inkscape {
    param(
        [string]$SourceSVG,
        [string]$TargetBMP,
        [int]$Size
    )

    try {
        # Inkscape konvertiert zu PNG, dann müssen wir zu BMP
        $tempPNG = [System.IO.Path]::GetTempFileName() + ".png"

        & inkscape --export-type=png --export-width=$Size --export-filename="$tempPNG" "$SourceSVG" 2>&1 | Out-Null

        if (Test-Path $tempPNG) {
            # PNG zu BMP konvertieren mit .NET
            $image = [System.Drawing.Image]::FromFile($tempPNG)
            $image.Save($TargetBMP, [System.Drawing.Imaging.ImageFormat]::Bmp)
            $image.Dispose()

            Remove-Item $tempPNG -Force
            return $true
        }

        return $false
    } catch {
        return $false
    }
}

function Convert-SVGtoBMP-DotNet {
    param(
        [string]$SourceSVG,
        [string]$TargetBMP,
        [int]$Size
    )

    Write-ColorOutput "Verwende .NET Konvertierung (Fallback)" "INFO"
    Write-ColorOutput "WARNUNG: .NET kann SVG nicht direkt rendern" "WARNING"
    Write-ColorOutput "Bitte installieren Sie ImageMagick oder Inkscape für bessere Qualität" "WARNING"

    # Erstelle ein einfaches Placeholder-BMP
    try {
        Add-Type -AssemblyName System.Drawing

        $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        # Roter Hintergrund als Platzhalter
        $graphics.Clear([System.Drawing.Color]::FromArgb(227, 6, 19))

        # Text hinzufügen
        $font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $text = [System.IO.Path]::GetFileNameWithoutExtension($TargetBMP)
        $graphics.DrawString($text, $font, $brush, 5, 20)

        $bitmap.Save($TargetBMP, [System.Drawing.Imaging.ImageFormat]::Bmp)

        $graphics.Dispose()
        $bitmap.Dispose()
        $font.Dispose()
        $brush.Dispose()

        return $true
    } catch {
        Write-ColorOutput "Fehler bei .NET Konvertierung: $_" "ERROR"
        return $false
    }
}

# ============================================================================
# HAUPTPROGRAMM
# ============================================================================

Show-Banner

# Aktuelles Verzeichnis
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$iconsPath = Join-Path $scriptPath "icons"
$outputPath = Join-Path $iconsPath "bmp"

Write-ColorOutput "Script-Verzeichnis: $scriptPath" "INFO"
Write-ColorOutput "Icons-Verzeichnis: $iconsPath" "INFO"
Write-ColorOutput "Output-Verzeichnis: $outputPath" "INFO"
Write-Host ""

# Prüfe Icons-Verzeichnis
if (-not (Test-Path $iconsPath)) {
    Write-ColorOutput "FEHLER: Icons-Verzeichnis nicht gefunden: $iconsPath" "ERROR"
    Read-Host "Drücken Sie ENTER zum Beenden"
    exit 1
}

# Output-Verzeichnis erstellen
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    Write-ColorOutput "Output-Verzeichnis erstellt" "SUCCESS"
}

# Prüfe verfügbare Konvertierungs-Tools
Write-ColorOutput "Prüfe verfügbare Konvertierungs-Tools..." "INFO"

$hasImageMagick = Test-ImageMagick
$hasInkscape = Test-Inkscape

if ($hasImageMagick) {
    Write-ColorOutput "✓ ImageMagick gefunden" "SUCCESS"
    $converter = "ImageMagick"
} elseif ($hasInkscape) {
    Write-ColorOutput "✓ Inkscape gefunden" "SUCCESS"
    $converter = "Inkscape"
} else {
    Write-ColorOutput "⚠ Keine optimalen Tools gefunden" "WARNING"
    Write-ColorOutput "Verwende .NET Fallback (eingeschränkte Qualität)" "WARNING"
    Write-Host ""
    Write-Host "Für bessere Qualität installieren Sie:"
    Write-Host "  - ImageMagick: https://imagemagick.org/script/download.php"
    Write-Host "  - Oder Inkscape: https://inkscape.org/release/"
    Write-Host ""
    $response = Read-Host "Trotzdem fortfahren? (J/N)"
    if ($response -ne "J" -and $response -ne "j") {
        exit 0
    }
    $converter = "DotNet"
}

Write-Host ""

# .NET System.Drawing laden
Add-Type -AssemblyName System.Drawing

# Konvertierung durchführen
$successCount = 0
$failCount = 0

foreach ($svgFile in $ICON_MAPPING.Keys) {
    $bmpFile = $ICON_MAPPING[$svgFile]
    $sourcePath = Join-Path $iconsPath $svgFile
    $targetPath = Join-Path $outputPath $bmpFile

    Write-Host "Konvertiere: $svgFile → $bmpFile" -NoNewline

    if (-not (Test-Path $sourcePath)) {
        Write-Host " [" -NoNewline
        Write-Host "FEHLT" -ForegroundColor Red -NoNewline
        Write-Host "]"
        $failCount++
        continue
    }

    $success = $false

    switch ($converter) {
        "ImageMagick" {
            $success = Convert-SVGtoBMP-ImageMagick -SourceSVG $sourcePath -TargetBMP $targetPath -Size $ICON_SIZE
        }
        "Inkscape" {
            $success = Convert-SVGtoBMP-Inkscape -SourceSVG $sourcePath -TargetBMP $targetPath -Size $ICON_SIZE
        }
        "DotNet" {
            $success = Convert-SVGtoBMP-DotNet -SourceSVG $sourcePath -TargetBMP $targetPath -Size $ICON_SIZE
        }
    }

    if ($success) {
        Write-Host " [" -NoNewline
        Write-Host "OK" -ForegroundColor Green -NoNewline
        Write-Host "]"
        $successCount++
    } else {
        Write-Host " [" -NoNewline
        Write-Host "FEHLER" -ForegroundColor Red -NoNewline
        Write-Host "]"
        $failCount++
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    KONVERTIERUNG ABGESCHLOSSEN                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-ColorOutput "Erfolgreich: $successCount" "SUCCESS"
if ($failCount -gt 0) {
    Write-ColorOutput "Fehlgeschlagen: $failCount" "ERROR"
}

Write-Host ""
Write-ColorOutput "BMP-Dateien gespeichert in: $outputPath" "INFO"
Write-Host ""

Write-Host "Folgende Dateien wurden erstellt:"
Get-ChildItem -Path $outputPath -Filter "*.bmp" | ForEach-Object {
    $size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  $($_.Name) ($size KB)"
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  NÄCHSTE SCHRITTE:" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Prüfen Sie die BMP-Dateien in: $outputPath"
Write-Host "  2. Kopieren Sie die *.bmp Dateien nach:"
Write-Host "     C:\EdingCNC5.3\icons\op_f_key\user\"
Write-Host "  3. Starten Sie Eding CNC neu"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Read-Host "Drücken Sie ENTER zum Beenden"
exit 0
