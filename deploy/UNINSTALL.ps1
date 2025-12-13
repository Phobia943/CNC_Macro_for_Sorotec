#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sorotec Eding CNC Macro V3.6 - Uninstaller
.DESCRIPTION
    Deinstalliert das CNC-Macro und Icons, stellt Backup wieder her
.NOTES
    Version: 1.0
    Author: Sorotec Macro Team
#>

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
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                                                                ║" -ForegroundColor Red
    Write-Host "║        SOROTEC EDING CNC MACRO V3.6 - UNINSTALLER             ║" -ForegroundColor Red
    Write-Host "║                                                                ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
}

function Get-LatestBackup {
    param(
        [string]$BackupDir,
        [string]$Pattern
    )

    if (-not (Test-Path $BackupDir)) {
        return $null
    }

    $backups = Get-ChildItem -Path $BackupDir -Filter $Pattern | Sort-Object LastWriteTime -Descending
    if ($backups.Count -gt 0) {
        return $backups[0].FullName
    }

    return $null
}

# ============================================================================
# HAUPTPROGRAMM
# ============================================================================

Show-Banner

# Eding CNC Pfad eingeben
Write-ColorOutput "Bitte geben Sie den Eding CNC Installationspfad ein:" "INFO"
$edingPath = Read-Host "(z.B. C:\Program Files\EdingCNC)"

if ([string]::IsNullOrWhiteSpace($edingPath) -or -not (Test-Path $edingPath)) {
    Write-ColorOutput "Ungültiger Pfad oder abgebrochen" "ERROR"
    Read-Host "Drücken Sie ENTER zum Beenden"
    exit 1
}

Write-ColorOutput "Eding CNC gefunden: $edingPath" "SUCCESS"
Write-Host ""

# Bestätigung
Write-ColorOutput "WARNUNG: Dies wird folgendes deinstallieren:" "WARNING"
Write-Host "  - macro.cnc (wird durch Backup ersetzt)"
Write-Host "  - icons/ Verzeichnis"
Write-Host "  - docs/ Verzeichnis"
Write-Host ""

$response = Read-Host "Möchten Sie fortfahren? (J/N)"
if ($response -ne "J" -and $response -ne "j" -and $response -ne "Y" -and $response -ne "y") {
    Write-ColorOutput "Deinstallation abgebrochen" "WARNING"
    exit 0
}

Write-Host ""

# Backup-Verzeichnis
$backupDir = Join-Path $edingPath "backups"

# ============================================================================
# MACRO WIEDERHERSTELLEN
# ============================================================================

Write-ColorOutput "Stelle macro.cnc wieder her..." "INFO"

# KORREKT: config/macro.cnc
$macroTarget = Join-Path $edingPath "config\macro.cnc"
$latestBackup = Get-LatestBackup -BackupDir $backupDir -Pattern "macro.cnc.backup_*"

if ($null -ne $latestBackup) {
    Write-ColorOutput "Gefundenes Backup: $latestBackup" "INFO"
    $restoreResponse = Read-Host "Dieses Backup wiederherstellen? (J/N)"

    if ($restoreResponse -eq "J" -or $restoreResponse -eq "j") {
        try {
            Copy-Item -Path $latestBackup -Destination $macroTarget -Force
            Write-ColorOutput "Backup wiederhergestellt" "SUCCESS"
        } catch {
            Write-ColorOutput "Fehler beim Wiederherstellen: $_" "ERROR"
        }
    } else {
        Write-ColorOutput "Backup nicht wiederhergestellt" "WARNING"
    }
} else {
    Write-ColorOutput "Kein Backup gefunden - macro.cnc wird gelöscht" "WARNING"
    $deleteResponse = Read-Host "macro.cnc löschen? (J/N)"

    if ($deleteResponse -eq "J" -or $deleteResponse -eq "j") {
        try {
            Remove-Item -Path $macroTarget -Force
            Write-ColorOutput "macro.cnc gelöscht" "SUCCESS"
        } catch {
            Write-ColorOutput "Fehler beim Löschen: $_" "ERROR"
        }
    }
}

Write-Host ""

# ============================================================================
# ICONS ENTFERNEN
# ============================================================================

Write-ColorOutput "Entferne Icons..." "INFO"

# KORREKT: icons/op_f_key/user
$iconsDir = Join-Path $edingPath "icons\op_f_key\user"

if (Test-Path $iconsDir) {
    $deleteIcons = Read-Host "User-Icons-Verzeichnis löschen? (J/N)"

    if ($deleteIcons -eq "J" -or $deleteIcons -eq "j") {
        try {
            Remove-Item -Path $iconsDir -Recurse -Force
            Write-ColorOutput "User-Icons-Verzeichnis gelöscht" "SUCCESS"
        } catch {
            Write-ColorOutput "Fehler beim Löschen: $_" "ERROR"
        }
    } else {
        Write-ColorOutput "Icons behalten" "INFO"
    }
} else {
    Write-ColorOutput "User-Icons-Verzeichnis nicht gefunden" "INFO"
}

Write-Host ""

# ============================================================================
# DOKUMENTATION ENTFERNEN
# ============================================================================

Write-ColorOutput "Entferne Dokumentation..." "INFO"

$docsDir = Join-Path $edingPath "docs"

if (Test-Path $docsDir) {
    $deleteDocs = Read-Host "Dokumentations-Verzeichnis löschen? (J/N)"

    if ($deleteDocs -eq "J" -or $deleteDocs -eq "j") {
        try {
            Remove-Item -Path $docsDir -Recurse -Force
            Write-ColorOutput "Dokumentations-Verzeichnis gelöscht" "SUCCESS"
        } catch {
            Write-ColorOutput "Fehler beim Löschen: $_" "ERROR"
        }
    } else {
        Write-ColorOutput "Dokumentation behalten" "INFO"
    }
} else {
    Write-ColorOutput "Dokumentations-Verzeichnis nicht gefunden" "INFO"
}

Write-Host ""

# ============================================================================
# BACKUPS ENTFERNEN (OPTIONAL)
# ============================================================================

Write-ColorOutput "Backups verwalten..." "INFO"

if (Test-Path $backupDir) {
    $deleteBackups = Read-Host "Backup-Verzeichnis auch löschen? (J/N)"

    if ($deleteBackups -eq "J" -or $deleteBackups -eq "j") {
        try {
            Remove-Item -Path $backupDir -Recurse -Force
            Write-ColorOutput "Backup-Verzeichnis gelöscht" "SUCCESS"
        } catch {
            Write-ColorOutput "Fehler beim Löschen: $_" "ERROR"
        }
    } else {
        Write-ColorOutput "Backups behalten (empfohlen)" "INFO"
    }
} else {
    Write-ColorOutput "Backup-Verzeichnis nicht gefunden" "INFO"
}

Write-Host ""

# ============================================================================
# ZUSAMMENFASSUNG
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║               DEINSTALLATION ABGESCHLOSSEN                     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-ColorOutput "WICHTIG: Starten Sie Eding CNC neu!" "WARNING"
Write-Host ""

Read-Host "Drücken Sie ENTER zum Beenden"
exit 0
