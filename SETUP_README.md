# 🚀 Setup & Installation

**Sorotec Eding CNC Macro V3.6** - Automatische Installation

---

## ⚡ Schnellstart

### Windows
```
Doppelklick auf: SETUP.bat
```

### Linux
```bash
chmod +x SETUP.sh
./SETUP.sh
```

### PowerShell (empfohlen)
```powershell
.\SETUP.ps1
```

---

## 📦 Verfügbare Setup-Scripts

| Datei | Plattform | Beschreibung |
|-------|-----------|--------------|
| **SETUP.ps1** | Windows PowerShell | ⭐ Empfohlen, vollständige Features |
| **SETUP.bat** | Windows Batch | Einfach, ohne PowerShell |
| **SETUP.sh** | Linux/Unix | Für Wine oder native Installation |
| **UNINSTALL.ps1** | Windows PowerShell | Deinstallation mit Backup-Wiederherstellung |

---

## 📋 Was wird installiert?

✅ **macro.cnc** → `EdingCNC/config/macro.cnc`
✅ **icons/** → `EdingCNC/icons/op_f_key/user/` (18 SVG-Icons)
✅ **docs/** → `EdingCNC/docs/`
✅ **backups/** → Automatische Backups

---

## 🔧 Installations-Optionen

### Option 1: Automatisch (Empfohlen)

Das Script **findet Eding CNC automatisch** in:
- `C:\Program Files\EdingCNC`
- `C:\Program Files (x86)\EdingCNC`
- `C:\EdingCNC`
- `D:\EdingCNC`

### Option 2: Manueller Pfad

Falls nicht gefunden:
```
Bitte Eding CNC Pfad eingeben: C:\MeinPfad\EdingCNC
```

---

## 🛡️ Sicherheit & Backups

### Automatische Backups

**JEDE Installation** erstellt automatisch Backups:

```
EdingCNC/backups/
├── macro.cnc.backup_20251127_143052
├── icons_backup_20251127_143052/
└── ...
```

### Wiederherstellung

**Manuell:**
```batch
copy "backups\macro.cnc.backup_ZEITSTEMPEL" "macro.cnc"
```

**Mit Uninstaller:**
```powershell
.\UNINSTALL.ps1
```

---

## ⚠️ Vor der Installation

### Checkliste

- [ ] Eding CNC ist installiert
- [ ] Eding CNC ist **NICHT** geöffnet
- [ ] Sie haben **Administrator-Rechte**
- [ ] Backup Ihres aktuellen Macros (optional, wird automatisch gemacht)

### Systemanforderungen

- Windows 7/8/10/11 oder Linux (Wine)
- Eding CNC 4.0 oder neuer
- ~500 KB freier Speicher

---

## 📖 Detaillierte Anleitung

**Siehe:** `INSTALLATION.md` (Vollständige Dokumentation)

---

## 🆘 Probleme?

### "PowerShell Script disabled"
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### "Zugriff verweigert"
- Als **Administrator** ausführen

### "Eding CNC nicht gefunden"
- Pfad manuell eingeben wenn gefragt

### Weitere Hilfe
→ Siehe `INSTALLATION.md` für detailliertes Troubleshooting

---

## 🔄 Nach der Installation

1. **Eding CNC neu starten**
2. Macro testen (z.B. user_2: Z-Nullpunkt)
3. Konfiguration anpassen (`config` in MDI)
4. Dokumentation lesen

---

## 🗑️ Deinstallation

### Windows PowerShell
```powershell
.\UNINSTALL.ps1
```

### Manuell
1. Backup aus `backups/` wiederherstellen
2. `icons/op_f_key/user/` löschen (optional)
3. `docs/` löschen (optional)

---

## 📊 Feature-Matrix

| Feature | PS1 | BAT | SH |
|---------|-----|-----|----|
| Auto-Erkennung | ✅ | ✅ | ✅ |
| Backup | ✅ | ✅ | ✅ |
| Icons | ✅ | ✅ | ✅ |
| Docs | ✅ | ✅ | ✅ |
| Farbige Ausgabe | ✅ | ⚠️ | ✅ |
| Fehlerbehandlung | ✅ | ⚠️ | ✅ |

✅ = Vollständig | ⚠️ = Eingeschränkt

---

## 📁 Projektstruktur

```
CNC_Macro_for_Sorotec/
├── macro.cnc                    ← Haupt-Makro (→ config/)
├── SETUP.ps1                    ← PowerShell Installer
├── SETUP.bat                    ← Batch Installer
├── SETUP.sh                     ← Linux/Unix Installer
├── UNINSTALL.ps1                ← Deinstaller
├── INSTALLATION.md              ← Detaillierte Anleitung
├── SETUP_README.md              ← Diese Datei
├── icons/
│   ├── user_1_tool_length.svg   ← Icons (→ op_f_key/user/)
│   ├── ...
│   └── ICON_OVERVIEW.md
└── docs/
    ├── README.md
    └── ...
```

---

## 💡 Tipps

### Tipp 1: Test-Installation

Installieren Sie zuerst auf einer **Test-Maschine** oder mit **nicht-produktiver** Konfiguration.

### Tipp 2: Backup sichern

Kopieren Sie `backups/` auf ein externes Laufwerk vor größeren Änderungen.

### Tipp 3: Icons anpassen

Icons können nachträglich angepasst werden:
```
EdingCNC/icons/ → SVG-Dateien editieren
```

Siehe: `icons/ICON_OVERVIEW.md`

### Tipp 4: Mehrere Installationen

Verschiedene Eding CNC Instanzen? Führen Sie Setup für jede Installation separat aus.

---

## 🎯 Best Practices

### Vor jeder CNC-Produktion

1. ✅ Backup prüfen
2. ✅ Test-Lauf durchführen
3. ✅ Dokumentation griffbereit haben

### Bei Updates

1. ✅ Alte Version deinstallieren
2. ✅ Neue Version installieren
3. ✅ Konfiguration prüfen

---

## 📞 Support

**Dokumentation:**
- `INSTALLATION.md` - Vollständige Installationsanleitung
- `README.md` - Makro-Dokumentation
- `icons/ICON_OVERVIEW.md` - Icon-Dokumentation

**Bei Problemen:**
1. Prüfen Sie `INSTALLATION.md` → Troubleshooting
2. Prüfen Sie Backups in `EdingCNC/backups/`
3. Erstellen Sie ein GitHub Issue

---

## ✨ Features der Setup-Scripts

### SETUP.ps1 (PowerShell)
- ✅ Automatische Pfad-Erkennung
- ✅ Vollständige Fehlerbehandlung
- ✅ Farbige Ausgabe mit Emojis
- ✅ Interaktive Bestätigung
- ✅ Detaillierte Zusammenfassung
- ✅ Exit-Codes für Automatisierung

### SETUP.bat (Batch)
- ✅ Einfache Bedienung
- ✅ Keine PowerShell erforderlich
- ✅ Windows 7+ kompatibel
- ✅ Automatische Backups
- ✅ Grundlegende Fehlerbehandlung

### SETUP.sh (Linux/Unix)
- ✅ Wine-Unterstützung
- ✅ Native Linux-Pfade
- ✅ POSIX-kompatibel
- ✅ Farbige Terminal-Ausgabe
- ✅ Automatische Backups

---

## 🔐 Sicherheit

### Was die Scripts NICHT tun:

- ❌ Keine Internet-Verbindung
- ❌ Keine System-Änderungen außerhalb Eding CNC
- ❌ Keine Registry-Modifikation
- ❌ Keine Dienste/Treiber installieren

### Was die Scripts tun:

- ✅ Nur Dateien in Eding CNC-Ordner kopieren
- ✅ Backups erstellen
- ✅ Ordner anlegen (icons, docs, backups)

**Scripts sind Open Source - vor Ausführung prüfbar!**

---

## 📜 Lizenz

Frei verwendbar für CNC-Projekte.

---

**Version:** 1.0
**Datum:** 2025-11-27
**Getestet mit:** Windows 10/11, Linux Mint 21 (Wine)
**Eding CNC:** 4.0-5.3
