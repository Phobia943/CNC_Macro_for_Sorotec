@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM Sorotec Eding CNC Macro V3.6 - Batch Installer
REM Einfacher Installer ohne PowerShell-Abhängigkeit
REM ============================================================================

title Sorotec Eding CNC Macro V3.6 - Installer

REM Farben definieren (für Windows 10+)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "CYAN=[96m"
set "RESET=[0m"

cls
echo.
echo %CYAN%════════════════════════════════════════════════════════════════%RESET%
echo %CYAN%                                                                %RESET%
echo %CYAN%        SOROTEC EDING CNC MACRO V3.6 - INSTALLER              %RESET%
echo %CYAN%                                                                %RESET%
echo %CYAN%           Automatische Installation (Batch-Version)           %RESET%
echo %CYAN%                                                                %RESET%
echo %CYAN%════════════════════════════════════════════════════════════════%RESET%
echo.

REM ============================================================================
REM Prüfe ob macro.cnc existiert
REM ============================================================================

if not exist "%~dp0macro.cnc" (
    echo %RED%FEHLER: macro.cnc nicht gefunden!%RESET%
    echo.
    echo Bitte fuehren Sie SETUP.bat aus dem Macro-Verzeichnis aus.
    echo Aktuelles Verzeichnis: %~dp0
    echo.
    pause
    exit /b 1
)

echo %GREEN%[OK]%RESET% macro.cnc gefunden
echo.

REM ============================================================================
REM Suche Eding CNC Installation
REM ============================================================================

echo %CYAN%Suche Eding CNC Installation...%RESET%
echo.

set "EDING_PATH="

REM Prüfe Standard-Pfade
if exist "C:\Program Files\EdingCNC\*" (
    set "EDING_PATH=C:\Program Files\EdingCNC"
    goto :found
)

if exist "C:\Program Files (x86)\EdingCNC\*" (
    set "EDING_PATH=C:\Program Files (x86)\EdingCNC"
    goto :found
)

if exist "C:\EdingCNC\*" (
    set "EDING_PATH=C:\EdingCNC"
    goto :found
)

if exist "D:\EdingCNC\*" (
    set "EDING_PATH=D:\EdingCNC"
    goto :found
)

REM Nicht gefunden - Benutzer fragen
echo %YELLOW%Eding CNC nicht in Standard-Pfaden gefunden%RESET%
echo.
set /p "EDING_PATH=Bitte Eding CNC Pfad eingeben (z.B. C:\EdingCNC): "

if "%EDING_PATH%"=="" (
    echo %RED%Installation abgebrochen%RESET%
    pause
    exit /b 1
)

if not exist "%EDING_PATH%\*" (
    echo %RED%FEHLER: Pfad nicht gefunden: %EDING_PATH%%RESET%
    pause
    exit /b 1
)

:found
echo %GREEN%[OK]%RESET% Eding CNC gefunden: %EDING_PATH%
echo.

REM ============================================================================
REM Bestätigung
REM ============================================================================

echo %YELLOW%WARNUNG: Existierende Dateien werden ueberschrieben!%RESET%
echo Ein Backup wird automatisch erstellt.
echo.
set /p "CONFIRM=Moechten Sie fortfahren? (J/N): "

if /i not "%CONFIRM%"=="J" if /i not "%CONFIRM%"=="Y" (
    echo %YELLOW%Installation abgebrochen%RESET%
    pause
    exit /b 0
)

echo.

REM ============================================================================
REM Backup erstellen
REM ============================================================================

echo %CYAN%Erstelle Backup...%RESET%

set "BACKUP_DIR=%EDING_PATH%\backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Zeitstempel erstellen (ohne WMIC - kompatibel mit Windows 11)
REM Format: YYYYMMDD_HHMMSS
for /f "tokens=1-6 delims=/: " %%a in ("%date% %time%") do (
    set "TIMESTAMP=%%c%%b%%a_%%d%%e%%f"
)
REM Leerzeichen in Nullen umwandeln
set "TIMESTAMP=%TIMESTAMP: =0%"

REM Macro backup (KORREKT: config/macro.cnc)
if exist "%EDING_PATH%\config\macro.cnc" (
    copy /Y "%EDING_PATH%\config\macro.cnc" "%BACKUP_DIR%\macro.cnc.backup_%TIMESTAMP%" >nul
    if errorlevel 1 (
        echo %RED%[FEHLER]%RESET% Backup von macro.cnc fehlgeschlagen
    ) else (
        echo %GREEN%[OK]%RESET% Backup erstellt: macro.cnc.backup_%TIMESTAMP%
    )
) else (
    echo %YELLOW%[INFO]%RESET% Kein vorhandenes Macro gefunden - kein Backup noetig
)

REM Icons backup
if exist "%EDING_PATH%\icons\*" (
    if not exist "%BACKUP_DIR%\icons_backup_%TIMESTAMP%" mkdir "%BACKUP_DIR%\icons_backup_%TIMESTAMP%"
    xcopy /Y /Q /E "%EDING_PATH%\icons\*" "%BACKUP_DIR%\icons_backup_%TIMESTAMP%\" >nul 2>&1
    if not errorlevel 1 (
        echo %GREEN%[OK]%RESET% Backup erstellt: icons_backup_%TIMESTAMP%
    )
)

echo.

REM ============================================================================
REM Macro installieren
REM ============================================================================

echo %CYAN%Installiere Macro...%RESET%

REM Config-Verzeichnis erstellen (falls nicht vorhanden)
if not exist "%EDING_PATH%\config" mkdir "%EDING_PATH%\config"

copy /Y "%~dp0macro.cnc" "%EDING_PATH%\config\macro.cnc" >nul
if errorlevel 1 (
    echo %RED%[FEHLER]%RESET% Macro-Installation fehlgeschlagen
    set "MACRO_SUCCESS=0"
) else (
    echo %GREEN%[OK]%RESET% Macro installiert: %EDING_PATH%\config\macro.cnc
    set "MACRO_SUCCESS=1"

    REM Dateigröße anzeigen
    for %%I in ("%EDING_PATH%\config\macro.cnc") do (
        set /a "SIZE_KB=%%~zI / 1024"
        echo        Dateigroesse: !SIZE_KB! KB
    )

    REM Macro-Konfigurationsdateien kopieren (für Tooltips/Namen)
    set "CONFIG_COUNT=0"
    if exist "%~dp0user_macro_names.txt" (
        copy /Y "%~dp0user_macro_names.txt" "%EDING_PATH%\config\" >nul
        if not errorlevel 1 set /a "CONFIG_COUNT+=1"
    )
    if exist "%~dp0user_macro_tooltips.txt" (
        copy /Y "%~dp0user_macro_tooltips.txt" "%EDING_PATH%\config\" >nul
        if not errorlevel 1 set /a "CONFIG_COUNT+=1"
    )
    if exist "%~dp0user_macros.ini" (
        copy /Y "%~dp0user_macros.ini" "%EDING_PATH%\config\" >nul
        if not errorlevel 1 set /a "CONFIG_COUNT+=1"
    )
    if !CONFIG_COUNT! gtr 0 (
        echo %GREEN%[OK]%RESET% Macro-Konfiguration installiert (!CONFIG_COUNT! Dateien)
    )
)

echo.

REM ============================================================================
REM Icons installieren
REM ============================================================================

echo %CYAN%Installiere Icons...%RESET%

if not exist "%~dp0icons\*" (
    echo %YELLOW%[INFO]%RESET% Icons-Verzeichnis nicht gefunden - uebersprungen
    set "ICONS_SUCCESS=0"
    goto :skip_icons
)

REM Icons-Verzeichnis erstellen (KORREKT: icons\op_f_key\user)
if not exist "%EDING_PATH%\icons\op_f_key\user" mkdir "%EDING_PATH%\icons\op_f_key\user"

REM SVG-Icons kopieren
set "ICON_COUNT=0"
for %%f in ("%~dp0icons\*.svg") do (
    copy /Y "%%f" "%EDING_PATH%\icons\op_f_key\user\" >nul
    if not errorlevel 1 set /a "ICON_COUNT+=1"
)

if !ICON_COUNT! gtr 0 (
    echo %GREEN%[OK]%RESET% !ICON_COUNT! SVG Icons installiert
    set "ICONS_SUCCESS=1"
) else (
    echo %YELLOW%[WARNUNG]%RESET% Keine SVG Icons installiert
    set "ICONS_SUCCESS=0"
)

REM BMP-Icons kopieren (aus icons\bmp\)
if exist "%~dp0icons\bmp\*.bmp" (
    set "BMP_COUNT=0"
    for %%f in ("%~dp0icons\bmp\*.bmp") do (
        copy /Y "%%f" "%EDING_PATH%\icons\op_f_key\user\" >nul
        if not errorlevel 1 set /a "BMP_COUNT+=1"
    )
    if !BMP_COUNT! gtr 0 (
        echo %GREEN%[OK]%RESET% !BMP_COUNT! BMP Icons installiert (UX.bmp Format)
    )
) else (
    echo %YELLOW%[INFO]%RESET% Keine BMP Icons gefunden (optional)
)

REM Dokumentation kopieren
if exist "%~dp0icons\*.md" (
    copy /Y "%~dp0icons\*.md" "%EDING_PATH%\icons\op_f_key\user\" >nul 2>&1
)
if exist "%~dp0icons\*.html" (
    copy /Y "%~dp0icons\*.html" "%EDING_PATH%\icons\op_f_key\user\" >nul 2>&1
)
if not errorlevel 1 (
    echo %GREEN%[OK]%RESET% Icon-Dokumentation kopiert
)

:skip_icons
echo.

REM ============================================================================
REM Dokumentation installieren
REM ============================================================================

echo %CYAN%Installiere Dokumentation...%RESET%

if not exist "%EDING_PATH%\docs" mkdir "%EDING_PATH%\docs"

set "DOC_COUNT=0"

if exist "%~dp0README.md" (
    copy /Y "%~dp0README.md" "%EDING_PATH%\docs\" >nul
    if not errorlevel 1 set /a "DOC_COUNT+=1"
)

if exist "%~dp0FEATURE_COMPARISON_MATRIX.md" (
    copy /Y "%~dp0FEATURE_COMPARISON_MATRIX.md" "%EDING_PATH%\docs\" >nul
    if not errorlevel 1 set /a "DOC_COUNT+=1"
)

if exist "%~dp0QUICK_COMPARISON_SUMMARY.md" (
    copy /Y "%~dp0QUICK_COMPARISON_SUMMARY.md" "%EDING_PATH%\docs\" >nul
    if not errorlevel 1 set /a "DOC_COUNT+=1"
)

if !DOC_COUNT! gtr 0 (
    echo %GREEN%[OK]%RESET% !DOC_COUNT! Dokumentations-Dateien installiert
) else (
    echo %YELLOW%[INFO]%RESET% Keine Dokumentation gefunden
)

echo.

REM ============================================================================
REM Zusammenfassung
REM ============================================================================

echo.
echo %GREEN%════════════════════════════════════════════════════════════════%RESET%
echo %GREEN%                 INSTALLATION ABGESCHLOSSEN                     %RESET%
echo %GREEN%════════════════════════════════════════════════════════════════%RESET%
echo.

echo Installationspfad: %EDING_PATH%
echo.

if "%MACRO_SUCCESS%"=="1" (
    echo %GREEN%[OK]%RESET% Macro installiert: %EDING_PATH%\config\macro.cnc
) else (
    echo %RED%[FEHLER]%RESET% Macro NICHT installiert
)

if "%ICONS_SUCCESS%"=="1" (
    echo %GREEN%[OK]%RESET% Icons installiert: %EDING_PATH%\icons\op_f_key\user\
) else (
    echo %YELLOW%[INFO]%RESET% Icons NICHT installiert
)

echo.
echo Backups gespeichert in: %EDING_PATH%\backups\
echo.

echo %CYAN%══════════════════════════════════════════════════════════════════%RESET%
echo %YELLOW%  NAECHSTE SCHRITTE:%RESET%
echo %CYAN%══════════════════════════════════════════════════════════════════%RESET%
echo.
echo   1. Starten Sie Eding CNC neu
echo   2. Pruefen Sie, ob das Macro geladen wurde
echo   3. Testen Sie die Funktionen vorsichtig!
echo   4. Lesen Sie die Dokumentation in: %EDING_PATH%\docs\
echo.
echo %CYAN%══════════════════════════════════════════════════════════════════%RESET%
echo.

pause
exit /b 0
