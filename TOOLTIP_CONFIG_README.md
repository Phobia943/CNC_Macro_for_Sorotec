# 🏷️ Tooltip-Konfiguration für Eding CNC Makros

**Version:** 3.6
**Datum:** 2025-11-27

---

## 📋 Übersicht

Das Sorotec Eding CNC Macro-Paket enthält jetzt Konfigurationsdateien, die benutzerfreundliche Namen und Tooltips für die Makro-Buttons aktivieren.

### Statt:
```
Benutzermakro 1 (Makro: user_1)
```

### Jetzt:
```
Werkzeuglaengenmessung
Misst die Laenge des eingespannten Werkzeugs mit Laengentaster
```

---

## 📁 Installierte Dateien

Die Setup-Scripts installieren automatisch folgende Konfigurationsdateien:

### 1. **user_macros.ini**
- **Speicherort:** `EdingCNC/config/user_macros.ini`
- **Format:** INI-Datei mit Sektionen
- **Inhalt:** Name, Beschreibung und Icon für jedes Makro
- **Verwendung:** Hauptkonfigurationsdatei für Eding CNC

### 2. **user_macro_names.txt**
- **Speicherort:** `EdingCNC/config/user_macro_names.txt`
- **Format:** Einfache Text-Datei (user_X=Name)
- **Inhalt:** Kurze Namen für jedes Makro
- **Verwendung:** Fallback für kurze Button-Beschriftungen

### 3. **user_macro_tooltips.txt**
- **Speicherort:** `EdingCNC/config/user_macro_tooltips.txt`
- **Format:** Text-Datei (user_X=Beschreibung)
- **Inhalt:** Ausführliche Tooltips beim Hovern
- **Verwendung:** Detaillierte Hover-Informationen

---

## 🚀 Installation

### Automatisch (Empfohlen)

Die Konfigurationsdateien werden automatisch installiert, wenn Sie eines der Setup-Scripts ausführen:

```powershell
# Windows PowerShell
.\SETUP.ps1

# Windows Batch
SETUP.bat

# Linux/Unix
./SETUP.sh
```

### Manuell

Falls Sie nur die Konfigurationsdateien aktualisieren möchten:

**Windows:**
```batch
copy user_macros.ini C:\EdingCNC5.3\config\
copy user_macro_names.txt C:\EdingCNC5.3\config\
copy user_macro_tooltips.txt C:\EdingCNC5.3\config\
```

**Linux:**
```bash
cp user_macros.ini ~/.wine/drive_c/EdingCNC5.3/config/
cp user_macro_names.txt ~/.wine/drive_c/EdingCNC5.3/config/
cp user_macro_tooltips.txt ~/.wine/drive_c/EdingCNC5.3/config/
```

---

## 🎯 Makro-Namen und Beschreibungen

| Makro | Name | Beschreibung | Icon |
|-------|------|--------------|------|
| **user_1** | Werkzeuglaengenmessung | Misst die Laenge des eingespannten Werkzeugs | U1.bmp |
| **user_2** | Z-Nullpunkt setzen | Setzt Z-Nullpunkt mit 3D-Taster | U2.bmp |
| **user_3** | Spindel Warmlauf | Waermt Spindel in 4 Stufen auf | U3.bmp |
| **user_4** | Werkzeugwechsel | Manueller Werkzeugwechsel | U4.bmp |
| **user_5** | Einzelkante antasten | Kante antasten + Nullpunkt setzen | U5.bmp |
| **user_6** | Ecke + Rotation | Findet Ecke und Rotation | U6.bmp |
| **user_7** | Loch-Mittelpunkt | Mittelpunkt eines Lochs finden | U7.bmp |
| **user_8** | Zylinder-Mittelpunkt | Mittelpunkt eines Zylinders finden | U8.bmp |
| **user_9** | Werkzeug-Bruchkontrolle | Prueft Werkzeug auf Bruch | U9.bmp |
| **user_10** | Rechteck vermessen | Misst alle 4 Kanten eines Rechtecks | U10.bmp |
| **user_11** | Dicke messen | Werkstueck-Dicke von oben nach unten | U11.bmp |
| **user_12** | Koordinaten-Manager | Verwaltet G54-G59 Nullpunkte | U12.bmp |

---

## ⚙️ Konfiguration in Eding CNC

### Schritt 1: Eding CNC neu starten

Nach der Installation der Konfigurationsdateien:
1. Schließen Sie Eding CNC komplett
2. Starten Sie Eding CNC neu
3. Die neuen Namen sollten automatisch erscheinen

### Schritt 2: Eding CNC Einstellungen prüfen

Falls die Tooltips nicht erscheinen, prüfen Sie:

1. **Menü → Einstellungen → Makros**
   - Aktivieren Sie "Benutzerdefinierte Makro-Namen anzeigen"
   - Aktivieren Sie "Makro-Tooltips anzeigen"

2. **Datei-Pfade prüfen:**
   ```
   C:\EdingCNC5.3\config\
   ├── macro.cnc
   ├── user_macros.ini          ← Muss vorhanden sein
   ├── user_macro_names.txt     ← Muss vorhanden sein
   └── user_macro_tooltips.txt  ← Muss vorhanden sein
   ```

### Schritt 3: Alternative Konfiguration

Falls Eding CNC die .ini Datei nicht automatisch erkennt:

1. Öffnen Sie `EdingCNC/config/cnc.ini` (Haupt-Konfiguration)
2. Suchen Sie nach `[UserMacros]` Sektion
3. Fügen Sie hinzu (falls nicht vorhanden):
   ```ini
   [UserMacros]
   ConfigFile=user_macros.ini
   ShowCustomNames=1
   ShowTooltips=1
   ```

---

## 🎨 Anpassung der Tooltips

### Namen und Beschreibungen ändern

Sie können die Namen und Beschreibungen jederzeit anpassen:

**1. Bearbeiten Sie user_macros.ini:**
```ini
[user_1]
Name=Mein eigener Name
Description=Meine eigene Beschreibung
Icon=U1.bmp
```

**2. Eding CNC neu starten**

### Eigene Icons zuweisen

Die Icons werden über die `Icon=` Zeile zugewiesen:
```ini
Icon=U1.bmp    ← Muss in icons/op_f_key/user/ liegen
```

---

## 🔧 Troubleshooting

### Problem: Tooltips erscheinen nicht

**Lösung 1: Datei-Pfade prüfen**
```batch
dir C:\EdingCNC5.3\config\user_*.*
```
Alle drei Dateien sollten vorhanden sein.

**Lösung 2: Eding CNC Einstellungen**
- Menü → Einstellungen → Makros
- "Tooltips anzeigen" aktivieren

**Lösung 3: Cache löschen**
1. Eding CNC schließen
2. Löschen Sie temporäre Dateien:
   ```
   C:\EdingCNC5.3\temp\*.*
   ```
3. Eding CNC neu starten

### Problem: Nur "user_1" wird angezeigt

**Ursache:** Format-Fehler in den Konfigurationsdateien

**Lösung:**
1. Öffnen Sie `user_macros.ini` in einem Text-Editor
2. Prüfen Sie, ob alle Sektionen korrekt formatiert sind:
   ```ini
   [user_1]
   Name=...
   Description=...
   Icon=...
   ```
3. Keine Leerzeichen vor den Zeilen!
4. Speichern Sie mit UTF-8 Encoding

### Problem: Umlaute werden falsch dargestellt

**Lösung:**
1. Öffnen Sie die Dateien in Notepad++
2. Wählen Sie "Kodierung → UTF-8" (ohne BOM)
3. Speichern Sie die Datei
4. Eding CNC neu starten

---

## 📖 Format-Referenz

### user_macros.ini Format

```ini
[user_X]              ; X = Makro-Nummer (1-12)
Name=Kurzname         ; Max. 30 Zeichen
Description=Text      ; Max. 120 Zeichen
Icon=UX.bmp           ; Dateiname in icons/op_f_key/user/
```

### user_macro_names.txt Format

```
user_X=Name           ; Eine Zeile pro Makro
```

### user_macro_tooltips.txt Format

```
user_X=Beschreibung   ; Eine Zeile pro Makro
```

---

## 💡 Best Practices

### Namen wählen

- **Kurz und prägnant:** Max. 30 Zeichen
- **Beschreibend:** Sofort verständlich
- **Konsistent:** Ähnliche Funktionen ähnlich benennen

### Beschreibungen schreiben

- **Klar und informativ:** Was macht das Makro?
- **Nicht zu lang:** Max. 120 Zeichen
- **Technische Details:** Welche Eingaben werden benötigt?

### Beispiele:

✅ **Gut:**
```
Name=Loch-Mittelpunkt
Description=Findet Mittelpunkt eines Lochs durch 4-Punkt-Messung
```

❌ **Schlecht:**
```
Name=user_7
Description=Tastet ein Loch an und macht irgendwas damit...
```

---

## 🔄 Updates

Bei Updates des Macro-Pakets:

1. **Backup erstellen:**
   ```batch
   copy C:\EdingCNC5.3\config\user_macros.ini user_macros.ini.backup
   ```

2. **Setup ausführen:**
   ```batch
   SETUP.bat
   ```

3. **Eigene Anpassungen wiederherstellen:**
   - Vergleichen Sie Backup mit neuer Datei
   - Übernehmen Sie Ihre Änderungen

---

## 📞 Support

**Probleme mit Tooltips?**

1. Prüfen Sie `EdingCNC/config/` auf die drei Dateien
2. Prüfen Sie Eding CNC Einstellungen
3. Prüfen Sie das Datei-Format (UTF-8)
4. Erstellen Sie ein GitHub Issue mit:
   - Eding CNC Version
   - Screenshot der Einstellungen
   - Inhalt von `user_macros.ini`

---

## 🎯 Zusammenfassung

✅ **Was installiert wurde:**
- 3 Konfigurationsdateien in `EdingCNC/config/`
- Namen für alle 12 Makros
- Tooltips mit detaillierten Beschreibungen
- Icon-Zuweisungen (U1.bmp - U12.bmp)

✅ **Was Sie sehen sollten:**
- Benutzerfreundliche Namen statt "user_X"
- Detaillierte Tooltips beim Hovern
- Icons neben den Makro-Buttons

✅ **Nächste Schritte:**
1. Eding CNC neu starten
2. Makro-Menü öffnen
3. Über Buttons hovern → Tooltips prüfen
4. Bei Bedarf Einstellungen anpassen

---

**Version:** 3.6
**Datum:** 2025-11-27
**Kompatibel mit:** Eding CNC 4.0-5.3
