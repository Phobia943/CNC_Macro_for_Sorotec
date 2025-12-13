#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sorotec Eding CNC Macro V3.6 - Installer
.DESCRIPTION
    Automatische Installation des CNC-Makros und Icons in Eding CNC
.NOTES
    Version: 1.0
    Author: Sorotec Macro Team
    Date: 2025-11-27
#>

# ============================================================================
# KONFIGURATION
# ============================================================================

$SCRIPT_VERSION = "3.6"
$SCRIPT_NAME = "Sorotec Eding CNC Macro"

# Typische Eding CNC Installationspfade
$EDING_PATHS = @(
    "C:\Program Files\EdingCNC",
    "C:\Program Files (x86)\EdingCNC",
    "C:\EdingCNC",
    "D:\EdingCNC",
    "$env:LOCALAPPDATA\EdingCNC",
    "$env:PROGRAMFILES\EdingCNC",
    "$env:PROGRAMFILES(x86)\EdingCNC"
)

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
        "STEP"    { Write-Host "`n▶ $Message" -ForegroundColor Magenta }
        default   { Write-Host $Message }
    }
}

function Show-Banner {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "║          SOROTEC EDING CNC MACRO V$SCRIPT_VERSION - INSTALLER           ║" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "║     Automatische Installation von Macro & Icons               ║" -ForegroundColor Cyan
    Write-Host "║                                                                ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Find-EdingCNC {
    Write-ColorOutput "Suche Eding CNC Installation..." "STEP"

    foreach ($path in $EDING_PATHS) {
        if (Test-Path $path) {
            Write-ColorOutput "Gefunden: $path" "SUCCESS"
            return $path
        }
    }

    Write-ColorOutput "Eding CNC nicht in Standard-Pfaden gefunden" "WARNING"

    # Benutzer fragen
    Write-Host ""
    $customPath = Read-Host "Bitte geben Sie den Eding CNC Installationspfad ein (oder ENTER zum Abbrechen)"

    if ([string]::IsNullOrWhiteSpace($customPath)) {
        Write-ColorOutput "Installation abgebrochen" "ERROR"
        exit 1
    }

    if (Test-Path $customPath) {
        Write-ColorOutput "Benutzerdefinierter Pfad akzeptiert: $customPath" "SUCCESS"
        return $customPath
    } else {
        Write-ColorOutput "Pfad nicht gefunden: $customPath" "ERROR"
        exit 1
    }
}

function Create-Backup {
    param(
        [string]$SourceFile,
        [string]$BackupDir
    )

    if (Test-Path $SourceFile) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $fileName = Split-Path $SourceFile -Leaf
        $backupFile = Join-Path $BackupDir "${fileName}.backup_${timestamp}"

        try {
            Copy-Item -Path $SourceFile -Destination $backupFile -Force
            Write-ColorOutput "Backup erstellt: $backupFile" "SUCCESS"
            return $backupFile
        } catch {
            Write-ColorOutput "Fehler beim Erstellen des Backups: $_" "ERROR"
            return $null
        }
    } else {
        Write-ColorOutput "Keine existierende Datei zum Backup gefunden" "INFO"
        return $null
    }
}

function Install-Macro {
    param(
        [string]$EdingPath,
        [string]$SourcePath
    )

    Write-ColorOutput "Installiere Macro..." "STEP"

    # Backup-Verzeichnis erstellen
    $backupDir = Join-Path $EdingPath "backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Write-ColorOutput "Backup-Verzeichnis erstellt: $backupDir" "INFO"
    }

    # Config-Verzeichnis erstellen (falls nicht vorhanden)
    $configDir = Join-Path $EdingPath "config"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        Write-ColorOutput "Config-Verzeichnis erstellt: $configDir" "INFO"
    }

    # Macro-Pfad (KORREKT: config/macro.cnc)
    $macroSource = Join-Path $SourcePath "macro.cnc"
    $macroTarget = Join-Path $configDir "macro.cnc"

    if (-not (Test-Path $macroSource)) {
        Write-ColorOutput "Macro-Datei nicht gefunden: $macroSource" "ERROR"
        return $false
    }

    # Backup erstellen
    if (Test-Path $macroTarget) {
        $backup = Create-Backup -SourceFile $macroTarget -BackupDir $backupDir
        if ($null -eq $backup) {
            Write-ColorOutput "Backup fehlgeschlagen. Installation abgebrochen." "ERROR"
            return $false
        }
    }

    # Macro kopieren
    try {
        Copy-Item -Path $macroSource -Destination $macroTarget -Force
        Write-ColorOutput "Macro installiert: $macroTarget" "SUCCESS"

        # Dateigröße anzeigen
        $fileSize = (Get-Item $macroTarget).Length
        $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
        Write-ColorOutput "Dateigröße: $fileSizeKB KB" "INFO"

        # Macro-Konfigurationsdateien kopieren (für Tooltips/Namen)
        $configFiles = @(
            "user_macro_names.txt",
            "user_macro_tooltips.txt",
            "user_macros.ini"
        )

        $configCopied = 0
        foreach ($configFile in $configFiles) {
            $configSource = Join-Path $SourcePath $configFile
            if (Test-Path $configSource) {
                $configTarget = Join-Path $configDir $configFile
                Copy-Item -Path $configSource -Destination $configTarget -Force
                $configCopied++
            }
        }

        if ($configCopied -gt 0) {
            Write-ColorOutput "Macro-Konfiguration installiert ($configCopied Dateien)" "SUCCESS"
        }

        return $true
    } catch {
        Write-ColorOutput "Fehler beim Kopieren des Macros: $_" "ERROR"
        return $false
    }
}

function Install-Icons {
    param(
        [string]$EdingPath,
        [string]$SourcePath
    )

    Write-ColorOutput "Installiere Icons..." "STEP"

    $iconsSource = Join-Path $SourcePath "icons"
    # KORREKT: icons/op_f_key/user/
    $iconsTarget = Join-Path $EdingPath "icons\op_f_key\user"

    if (-not (Test-Path $iconsSource)) {
        Write-ColorOutput "Icons-Verzeichnis nicht gefunden: $iconsSource" "WARNING"
        Write-ColorOutput "Icons werden übersprungen" "INFO"
        return $true
    }

    # Icons-Verzeichnis erstellen (inkl. Unterverzeichnisse)
    if (-not (Test-Path $iconsTarget)) {
        New-Item -ItemType Directory -Path $iconsTarget -Force | Out-Null
        Write-ColorOutput "Icons-Verzeichnis erstellt: $iconsTarget" "INFO"
    }

    # Backup von existierenden Icons
    if (Test-Path $iconsTarget) {
        $backupDir = Join-Path $EdingPath "backups"
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $iconsBackup = Join-Path $backupDir "icons_backup_${timestamp}"

        try {
            if ((Get-ChildItem $iconsTarget -File).Count -gt 0) {
                Copy-Item -Path $iconsTarget -Destination $iconsBackup -Recurse -Force
                Write-ColorOutput "Icons-Backup erstellt: $iconsBackup" "SUCCESS"
            }
        } catch {
            Write-ColorOutput "Warnung: Icons-Backup fehlgeschlagen: $_" "WARNING"
        }
    }

    # Icons kopieren
    try {
        # SVG Icons kopieren
        $iconFiles = Get-ChildItem -Path $iconsSource -Filter "*.svg" -File
        $copiedCount = 0

        foreach ($icon in $iconFiles) {
            $targetFile = Join-Path $iconsTarget $icon.Name
            Copy-Item -Path $icon.FullName -Destination $targetFile -Force
            $copiedCount++
        }

        Write-ColorOutput "$copiedCount SVG Icons installiert" "SUCCESS"

        # BMP Icons kopieren (aus icons/bmp/)
        $bmpSource = Join-Path $iconsSource "bmp"
        if (Test-Path $bmpSource) {
            $bmpFiles = Get-ChildItem -Path $bmpSource -Filter "*.bmp" -File
            $bmpCount = 0

            foreach ($bmp in $bmpFiles) {
                $targetFile = Join-Path $iconsTarget $bmp.Name
                Copy-Item -Path $bmp.FullName -Destination $targetFile -Force
                $bmpCount++
            }

            Write-ColorOutput "$bmpCount BMP Icons installiert (UX.bmp Format)" "SUCCESS"
        } else {
            Write-ColorOutput "Keine BMP Icons gefunden (optional)" "INFO"
        }

        # Dokumentation kopieren
        $docs = Get-ChildItem -Path $iconsSource -Filter "*.md" -File
        $docs += Get-ChildItem -Path $iconsSource -Filter "*.html" -File

        foreach ($doc in $docs) {
            $targetFile = Join-Path $iconsTarget $doc.Name
            Copy-Item -Path $doc.FullName -Destination $targetFile -Force
        }

        Write-ColorOutput "Icon-Dokumentation kopiert" "INFO"

        return $true
    } catch {
        Write-ColorOutput "Fehler beim Kopieren der Icons: $_" "ERROR"
        return $false
    }
}

function Install-Documentation {
    param(
        [string]$EdingPath,
        [string]$SourcePath
    )

    Write-ColorOutput "Installiere Dokumentation..." "STEP"

    $docsTarget = Join-Path $EdingPath "docs"

    if (-not (Test-Path $docsTarget)) {
        New-Item -ItemType Directory -Path $docsTarget -Force | Out-Null
    }

    $docFiles = @(
        "README.md",
        "FEATURE_COMPARISON_MATRIX.md",
        "QUICK_COMPARISON_SUMMARY.md"
    )

    $copiedCount = 0
    foreach ($docFile in $docFiles) {
        $sourcePath = Join-Path $SourcePath $docFile
        if (Test-Path $sourcePath) {
            $targetPath = Join-Path $docsTarget $docFile
            Copy-Item -Path $sourcePath -Destination $targetPath -Force
            $copiedCount++
        }
    }

    if ($copiedCount -gt 0) {
        Write-ColorOutput "$copiedCount Dokumentations-Dateien installiert" "SUCCESS"
    }

    return $true
}

function Show-Summary {
    param(
        [string]$EdingPath,
        [bool]$MacroInstalled,
        [bool]$IconsInstalled
    )

    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                   INSTALLATION ABGESCHLOSSEN                   ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Write-ColorOutput "Installationspfad: $EdingPath" "INFO"
    Write-Host ""

    if ($MacroInstalled) {
        Write-ColorOutput "✓ Macro installiert: $EdingPath\config\macro.cnc" "SUCCESS"
    } else {
        Write-ColorOutput "✗ Macro NICHT installiert" "ERROR"
    }

    if ($IconsInstalled) {
        Write-ColorOutput "✓ Icons installiert: $EdingPath\icons\op_f_key\user\" "SUCCESS"
    } else {
        Write-ColorOutput "⚠ Icons NICHT installiert" "WARNING"
    }

    Write-Host ""
    Write-ColorOutput "Backups gespeichert in: $EdingPath\backups\" "INFO"
    Write-Host ""

    Write-Host "══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  NÄCHSTE SCHRITTE:" -ForegroundColor Yellow
    Write-Host "══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Starten Sie Eding CNC neu" -ForegroundColor White
    Write-Host "  2. Prüfen Sie, ob das Macro geladen wurde" -ForegroundColor White
    Write-Host "  3. Testen Sie die Funktionen vorsichtig!" -ForegroundColor White
    Write-Host "  4. Lesen Sie die Dokumentation in: $EdingPath\docs\" -ForegroundColor White
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Confirm-Installation {
    Write-Host ""
    Write-ColorOutput "WARNUNG: Existierende Macro-Dateien werden überschrieben!" "WARNING"
    Write-ColorOutput "Ein Backup wird automatisch erstellt." "INFO"
    Write-Host ""

    $response = Read-Host "Möchten Sie fortfahren? (J/N)"

    return ($response -eq "J" -or $response -eq "j" -or $response -eq "Y" -or $response -eq "y")
}

# ============================================================================
# HAUPTPROGRAMM
# ============================================================================

Show-Banner

# Aktuelles Verzeichnis (wo das Script liegt)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-ColorOutput "Script-Verzeichnis: $scriptPath" "INFO"

# Prüfe ob macro.cnc existiert
$macroPath = Join-Path $scriptPath "macro.cnc"
if (-not (Test-Path $macroPath)) {
    Write-ColorOutput "FEHLER: macro.cnc nicht gefunden in: $scriptPath" "ERROR"
    Write-ColorOutput "Bitte führen Sie das Script aus dem Macro-Verzeichnis aus!" "ERROR"
    Write-Host ""
    Read-Host "Drücken Sie ENTER zum Beenden"
    exit 1
}

# Eding CNC finden
$edingPath = Find-EdingCNC

# Bestätigung
if (-not (Confirm-Installation)) {
    Write-ColorOutput "Installation abgebrochen vom Benutzer" "WARNING"
    exit 0
}

# Installation durchführen
$macroSuccess = Install-Macro -EdingPath $edingPath -SourcePath $scriptPath
$iconsSuccess = Install-Icons -EdingPath $edingPath -SourcePath $scriptPath
$docsSuccess = Install-Documentation -EdingPath $edingPath -SourcePath $scriptPath

# Zusammenfassung
Show-Summary -EdingPath $edingPath -MacroInstalled $macroSuccess -IconsInstalled $iconsSuccess

# Warten auf Benutzereingabe
Write-Host ""
Read-Host "Drücken Sie ENTER zum Beenden"

# Beenden mit entsprechendem Exit-Code
if ($macroSuccess) {
    exit 0
} else {
    exit 1
}
