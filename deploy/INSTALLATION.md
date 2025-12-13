# 📦 Installations-Anleitung

**Sorotec Eding CNC Macro V3.6**

Automatische Installation mit Setup-Scripts für Windows und Linux.

---

## 🚀 Schnellstart

### Windows (empfohlen)

**Methode 1: PowerShell (Beste Option)**
1. Rechtsklick auf `SETUP.ps1`
2. "Mit PowerShell ausführen" wählen
3. Falls Fehlermeldung: siehe Troubleshooting unten

**Methode 2: Batch (Einfach)**
1. Doppelklick auf `SETUP.bat`
2. Anweisungen folgen

### Linux / Unix

```bash
chmod +x SETUP.sh
./SETUP.sh
```

---

## 📋 Was wird installiert?

### Dateien
- ✅ **macro.cnc** → `EdingCNC/config/macro.cnc`
- ✅ **icons/** → `EdingCNC/icons/op_f_key/user/` (18 SVG-Icons)
- ✅ **Dokumentation** → `EdingCNC/docs/`

### Automatisch erstellt
- 📁 **backups/** → Automatische Backups aller ersetzten Dateien
- 📄 **Backup mit Zeitstempel** (z.B. macro.cnc.backup_20251127_143052)

---

## 🔧 Detaillierte Installations-Anleitung

### Windows PowerShell (EMPFOHLEN)

#### Schritt 1: PowerShell-Script starten

**Option A: Direkter Start**
```powershell
# Im Datei-Explorer:
1. Rechtsklick auf SETUP.ps1
2. "Mit PowerShell ausführen" wählen
3. Bei Sicherheitswarnung: "Einmal ausführen" wählen
```

**Option B: Über PowerShell-Konsole**
```powershell
# PowerShell als Administrator öffnen
cd "C:\Pfad\zum\Macro\Verzeichnis"
.\SETUP.ps1
```

#### Schritt 2: Execution Policy (falls erforderlich)

Wenn Sie die Fehlermeldung sehen:
```
cannot be loaded because running scripts is disabled
```

**Temporär erlauben (sicher):**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\SETUP.ps1
```

**Permanent erlauben (für fortgeschrittene Benutzer):**
```powershell
Set-ExecutionPolicy RemoteSigned
```

#### Schritt 3: Installation durchführen

Das Script wird:
1. ✅ Eding CNC automatisch finden
2. ✅ Aktuelles Macro sichern
3. ✅ Neues Macro installieren
4. ✅ Icons kopieren
5. ✅ Zusammenfassung anzeigen

---

### Windows Batch

#### Einfachste Methode - Doppelklick

1. **Doppelklick** auf `SETUP.bat`
2. Fenster öffnet sich
3. Anweisungen folgen
4. Bei Aufforderung bestätigen (J/N)

#### Manuelle Pfad-Eingabe

Falls Eding CNC nicht automatisch gefunden wird:
```
Bitte Eding CNC Pfad eingeben: C:\EdingCNC
```

Typische Pfade:
- `C:\Program Files\EdingCNC`
- `C:\Program Files (x86)\EdingCNC`
- `C:\EdingCNC`
- `D:\EdingCNC`

---

### Linux / Unix (Wine)

#### Schritt 1: Script ausführbar machen

```bash
chmod +x SETUP.sh
```

#### Schritt 2: Installation starten

```bash
./SETUP.sh
```

#### Schritt 3: Pfad angeben (falls erforderlich)

Typische Wine-Pfade:
```bash
~/.wine/drive_c/Program Files/EdingCNC
~/.wine/drive_c/EdingCNC
/opt/EdingCNC
```

---

## 📂 Installations-Pfade

### Eding CNC wird gesucht in:

**Windows:**
```
C:\Program Files\EdingCNC
C:\Program Files (x86)\EdingCNC
C:\EdingCNC
D:\EdingCNC
```

**Linux (Wine):**
```
~/.wine/drive_c/Program Files/EdingCNC
~/.wine/drive_c/EdingCNC
/opt/EdingCNC
```

### Nach der Installation:

```
EdingCNC/
├── config/
│   └── macro.cnc                       ← NEUES MACRO (HIER!)
├── icons/
│   └── op_f_key/
│       └── user/
│           ├── user_1_tool_length.svg  ← 18 Icons (HIER!)
│           ├── user_2_z_zero.svg
│           ├── ...
│           ├── ICON_PREVIEW.html       ← Icon-Vorschau
│           └── ICON_OVERVIEW.md        ← Icon-Dokumentation
├── docs/
│   ├── README.md
│   ├── FEATURE_COMPARISON_MATRIX.md
│   └── QUICK_COMPARISON_SUMMARY.md
└── backups/
    ├── macro.cnc.backup_20251127_143052
    └── icons_backup_20251127_143052/
```

---

## 🔄 Backup & Wiederherstellung

### Automatisches Backup

Bei jeder Installation werden **automatisch** Backups erstellt:

```
EdingCNC/backups/
├── macro.cnc.backup_20251127_143052
├── macro.cnc.backup_20251126_091234
└── icons_backup_20251127_143052/
```

**Zeitstempel-Format:** `JJJJMMTT_HHMMSS`

### Manuelles Wiederherstellen

**Windows:**
```batch
copy "C:\EdingCNC\backups\macro.cnc.backup_20251127_143052" "C:\EdingCNC\config\macro.cnc"
```

**Linux:**
```bash
cp ~/.wine/drive_c/EdingCNC/backups/macro.cnc.backup_20251127_143052 ~/.wine/drive_c/EdingCNC/config/macro.cnc
```

### Deinstallation

Nutzen Sie die Uninstaller-Scripts (siehe unten) oder:

1. Letztes Backup wiederherstellen
2. `icons/op_f_key/user/` Ordner löschen (optional)
3. `docs/` Ordner löschen (optional)

---

## ⚠️ Troubleshooting

### Problem: "PowerShell script disabled"

**Lösung:**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Problem: "Eding CNC nicht gefunden"

**Lösung:**
1. Prüfen Sie den tatsächlichen Installationspfad
2. Geben Sie den Pfad manuell ein wenn gefragt
3. Stellen Sie sicher, dass Eding CNC installiert ist

### Problem: "Zugriff verweigert"

**Lösung (Windows):**
- Script als **Administrator** ausführen
- Rechtsklick → "Als Administrator ausführen"

**Lösung (Linux):**
```bash
sudo ./SETUP.sh
```

### Problem: "macro.cnc nicht gefunden"

**Lösung:**
- Führen Sie das Setup-Script **aus dem gleichen Verzeichnis** aus wie macro.cnc
- Prüfen Sie: `ls` (Linux) oder `dir` (Windows)

### Problem: Icons werden nicht angezeigt

**Ursache:**
- Icons-Ordner fehlt im Quellverzeichnis
- Eding CNC GUI unterstützt möglicherweise keine benutzerdefinierten Icons

**Lösung:**
- Icons manuell in GUI einbinden
- Siehe: `icons/ICON_OVERVIEW.md`

---

## ✅ Nach der Installation

### 1. Eding CNC neu starten

**WICHTIG:** Eding CNC muss neu gestartet werden, damit das Macro geladen wird!

### 2. Macro testen

1. Öffnen Sie Eding CNC
2. Gehen Sie zu "Macro" → "User Macros"
3. Testen Sie eine einfache Funktion (z.B. user_2: Z-Nullpunkt)

### 3. Konfiguration anpassen

Das Macro enthält Standardwerte für **Sorotec Aluline AL1110**.

**Konfiguration ändern:**
1. In Eding CNC: MDI-Modus
2. Eingabe: `config` oder `user_13`
3. Parameter anpassen

**Oder manuell in macro.cnc:**
```
Zeile 74-238: Globale Parameter
```

### 4. Dokumentation lesen

**Wichtige Dokumente:**
```
EdingCNC/docs/README.md                          → Haupt-Dokumentation
EdingCNC/docs/FEATURE_COMPARISON_MATRIX.md       → Feature-Vergleich
EdingCNC/icons/ICON_PREVIEW.html                 → Icon-Vorschau (Browser öffnen!)
```

---

## 🔓 Deinstallation

### Option 1: Uninstaller verwenden

**Windows:**
```batch
UNINSTALL.bat
```

**PowerShell:**
```powershell
.\UNINSTALL.ps1
```

**Linux:**
```bash
chmod +x UNINSTALL.sh
./UNINSTALL.sh
```

### Option 2: Manuell

1. Letztes Backup aus `backups/` wiederherstellen
2. `icons/` Ordner löschen (optional)
3. `docs/` Ordner löschen (optional)
4. Eding CNC neu starten

---

## 📊 Installations-Matrix

| Plattform | Script | Administrator | Empfohlen |
|-----------|--------|---------------|-----------|
| Windows 10/11 | SETUP.ps1 | Ja | ⭐⭐⭐⭐⭐ |
| Windows 7/8 | SETUP.bat | Ja | ⭐⭐⭐⭐ |
| Windows (alle) | SETUP.bat | Nein möglich | ⭐⭐⭐ |
| Linux (Wine) | SETUP.sh | Empfohlen | ⭐⭐⭐⭐ |
| Linux (nativ) | SETUP.sh | Ja | ⭐⭐⭐ |

---

## 🆘 Hilfe & Support

### Bei Problemen:

1. **Backup prüfen:** Wurden Backups erstellt in `backups/`?
2. **Logs prüfen:** Hat das Script Fehler ausgegeben?
3. **Pfade prüfen:** Ist Eding CNC korrekt installiert?
4. **Rechte prüfen:** Script als Administrator ausführen?

### Kontakt:

- GitHub Issues: [Projektlink]
- Dokumentation: `README.md`
- Icon-Hilfe: `icons/ICON_OVERVIEW.md`

---

## 📝 Versionshinweise

**V3.6:**
- ✅ Automatischer Installer für Windows/Linux
- ✅ Automatische Backups mit Zeitstempel
- ✅ Icon-Installation
- ✅ Dokumentations-Installation
- ✅ Pfad-Auto-Erkennung
- ✅ Uninstaller-Support

---

## 🔐 Sicherheit

### Was das Script NICHT tut:

- ❌ Keine Internetverbindung
- ❌ Keine Systemänderungen außerhalb Eding CNC
- ❌ Keine Registry-Änderungen
- ❌ Keine Dienste installieren
- ❌ Keine Treiber installieren

### Was das Script tut:

- ✅ Nur Dateien kopieren
- ✅ Backups erstellen
- ✅ Ordner erstellen (icons, docs, backups)
- ✅ Eding CNC-Verzeichnis beschreiben

**Script ist Open Source und kann vor Ausführung geprüft werden!**

---

## 📜 Lizenz

Frei verwendbar für CNC-Projekte.
Siehe Hauptdokumentation für Details.

---

**Version:** 1.0
**Datum:** 2025-11-27
**Getestet:** Windows 10/11, Linux Mint 21 (Wine)
