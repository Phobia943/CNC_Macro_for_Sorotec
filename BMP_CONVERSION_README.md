# 🎨 BMP-Konvertierung für Eding CNC Icons

**Eding CNC benötigt Icons im BMP-Format mit spezifischer Benennung**

---

## 📋 Icon-Benennung (UX.bmp Schema)

| SVG-Datei | BMP-Datei | Macro-Funktion |
|-----------|-----------|----------------|
| user_1_tool_length.svg | **U1.bmp** | Werkzeuglängenmessung |
| user_2_z_zero.svg | **U2.bmp** | Z-Nullpunktermittlung |
| user_3_spindle_warmup.svg | **U3.bmp** | Spindel-Warmlauf |
| user_4_tool_change.svg | **U4.bmp** | Werkzeugwechsel |
| user_5_edge_probe.svg | **U5.bmp** | Einzelkanten-Antastung |
| user_6_corner_rotation.svg | **U6.bmp** | Ecken + Rotation |
| user_7_hole_probe.svg | **U7.bmp** | Loch-Antastung |
| user_8_cylinder_probe.svg | **U8.bmp** | Zylinder-Antastung |
| user_9_break_check.svg | **U9.bmp** | Werkzeug-Bruchkontrolle |
| user_10_rectangle_measure.svg | **U10.bmp** | Rechteck-Vermessung |
| user_11_thickness_measure.svg | **U11.bmp** | Dicken-Messung |
| user_12_coordinate_manager.svg | **U12.bmp** | Koordinatensystem-Manager |

---

## 🚀 Schnellstart

### Option 1: PowerShell (Windows - Empfohlen)

```powershell
.\CONVERT_TO_BMP.ps1
```

### Option 2: Python (Plattformunabhängig)

```bash
# Abhängigkeiten installieren
pip install cairosvg pillow

# Konvertierung starten
python convert_to_bmp.py
```

---

## 📦 Detaillierte Anleitungen

### Windows PowerShell-Script

**Voraussetzungen:**
- Windows PowerShell 5.1+
- Optional: ImageMagick oder Inkscape für beste Qualität

**Schritte:**

1. **PowerShell öffnen** im Projekt-Verzeichnis

2. **Script ausführen:**
   ```powershell
   .\CONVERT_TO_BMP.ps1
   ```

3. **Konvertierungs-Tool wird automatisch erkannt:**
   - ImageMagick (beste Qualität) ✅
   - Inkscape (sehr gut) ✅
   - .NET Fallback (eingeschränkt) ⚠️

4. **BMP-Dateien werden erstellt in:**
   ```
   icons/bmp/
   ├── U1.bmp
   ├── U2.bmp
   ├── ...
   └── U12.bmp
   ```

---

### Python-Script (Universal)

**Voraussetzungen:**
- Python 3.7+
- Eine der folgenden Bibliotheken:

**Empfohlen (beste Qualität):**
```bash
pip install cairosvg pillow
```

**Alternative 1:**
```bash
pip install svglib pillow reportlab
```

**Alternative 2:**
```bash
pip install wand
```

**Fallback (nur Pillow):**
```bash
pip install pillow
```

**Ausführen:**

```bash
# Linux/Mac
chmod +x convert_to_bmp.py
./convert_to_bmp.py

# Windows
python convert_to_bmp.py
```

---

## 🔧 Manuelle Konvertierung

Falls Scripts nicht funktionieren, können Sie Online-Tools nutzen:

### Online-Konverter

1. **CloudConvert:** https://cloudconvert.com/svg-to-bmp
   - Alle 12 SVG-Dateien hochladen
   - Format wählen: BMP
   - Größe: 64x64 Pixel
   - Herunterladen

2. **Convertio:** https://convertio.co/svg-bmp/

3. **SVG to BMP:** https://svgtobmp.com/

**Nach Download:**
- Dateien umbenennen nach UX.bmp Schema (siehe Tabelle oben)
- Kopieren nach: `C:\EdingCNC5.3\icons\op_f_key\user\`

---

## 🖼️ Manuelle Konvertierung mit Software

### Mit Inkscape (Desktop)

```bash
# Installation
# Windows: https://inkscape.org/release/
# Linux: sudo apt install inkscape

# Einzelnes Icon
inkscape --export-type=png --export-width=64 user_1_tool_length.svg

# PNG zu BMP konvertieren (mit ImageMagick)
magick convert user_1_tool_length.png U1.bmp
```

### Mit GIMP (Desktop)

1. SVG in GIMP öffnen
2. Bild → Skalieren → 64x64 Pixel
3. Bild → Modus → RGB
4. Datei → Exportieren als → BMP
5. Als U1.bmp speichern
6. Wiederholen für alle Icons

---

## 📁 Installation der BMP-Dateien

### Automatisch mit Setup-Scripts (Empfohlen)

Nach der Konvertierung können Sie die BMPs automatisch installieren mit:

**Windows PowerShell:**
```powershell
.\SETUP.ps1
```

**Windows Batch:**
```batch
SETUP.bat
```

**Linux/Unix:**
```bash
./SETUP.sh
```

Die Setup-Scripts erkennen automatisch die BMP-Icons in `icons/bmp/` und installieren sie zusammen mit den SVG-Icons und dem Macro.

### Manuell (nach Konvertierung)

Die BMPs liegen in:
```
icons/bmp/
├── U1.bmp
├── U2.bmp
├── ...
└── U12.bmp
```

**Kopieren nach Eding CNC:**

**Windows (CMD):**
```batch
xcopy /Y icons\bmp\*.bmp C:\EdingCNC5.3\icons\op_f_key\user\
```

**Windows (PowerShell):**
```powershell
Copy-Item icons\bmp\*.bmp C:\EdingCNC5.3\icons\op_f_key\user\ -Force
```

**Linux:**
```bash
cp icons/bmp/*.bmp ~/.wine/drive_c/EdingCNC5.3/icons/op_f_key/user/
```

### Manuell (im Explorer)

1. Öffnen Sie: `icons/bmp/`
2. Markieren Sie alle U*.bmp Dateien
3. Kopieren Sie sie nach:
   ```
   C:\EdingCNC5.3\icons\op_f_key\user\
   ```
4. Starten Sie Eding CNC neu

---

## ✅ Überprüfung

### Nach Installation prüfen:

```
C:\EdingCNC5.3\icons\op_f_key\user\
├── U1.bmp   ← Werkzeuglängenmessung
├── U2.bmp   ← Z-Nullpunkt
├── U3.bmp   ← Spindel-Warmlauf
├── U4.bmp   ← Werkzeugwechsel
├── U5.bmp   ← Einzelkanten
├── U6.bmp   ← Ecken + Rotation
├── U7.bmp   ← Loch-Antastung
├── U8.bmp   ← Zylinder-Antastung
├── U9.bmp   ← Bruchkontrolle
├── U10.bmp  ← Rechteck-Vermessung
├── U11.bmp  ← Dicken-Messung
└── U12.bmp  ← Koordinatensystem-Manager
```

### In Eding CNC prüfen:

1. Starten Sie Eding CNC 5.3 neu
2. Öffnen Sie das Macro-Menü
3. Die Icons sollten nun neben den Funktionen erscheinen

---

## 🎯 Technische Spezifikationen

### BMP-Format für Eding CNC:

- **Format:** Windows BMP (24-bit RGB)
- **Größe:** 64x64 Pixel (empfohlen)
- **Farbtiefe:** 24-bit (True Color)
- **Kompression:** Keine
- **Hintergrund:** Transparent wird zu Weiß konvertiert

### Dateinamen-Schema:

```
UX.bmp
 │
 └─ X = Macro-Nummer (1-12)

Beispiele:
U1.bmp  = user_1
U2.bmp  = user_2
U12.bmp = user_12
```

---

## ⚠️ Troubleshooting

### Problem: PowerShell-Script findet keine Tools

**Lösung:**
```
Installieren Sie ImageMagick oder Inkscape:
- ImageMagick: https://imagemagick.org/script/download.php
- Inkscape: https://inkscape.org/release/

Oder nutzen Sie das Python-Script
```

### Problem: Python-Script fehlt Bibliothek

**Lösung:**
```bash
pip install cairosvg pillow
```

### Problem: BMP-Dateien zeigen nicht in Eding CNC

**Mögliche Ursachen:**
1. Falscher Pfad → Prüfen Sie: `C:\EdingCNC5.3\icons\op_f_key\user\`
2. Falsche Benennung → Muss UX.bmp sein (nicht UX.bmp.bmp)
3. Eding CNC Neustart → Starten Sie Eding CNC neu
4. Format falsch → Muss 24-bit BMP sein

**Lösung:**
```
1. Prüfen Sie den Pfad
2. Prüfen Sie die Dateinamen (genau U1.bmp, U2.bmp, ...)
3. Starten Sie Eding CNC neu
```

### Problem: Icons sind verpixelt/schlecht

**Lösung:**
```
1. Verwenden Sie ImageMagick oder cairosvg für beste Qualität
2. Nicht den .NET Fallback nutzen
3. Ggf. manuell mit Inkscape oder GIMP konvertieren
```

---

## 💡 Tipps

### Tipp 1: Beste Qualität

Für beste Icon-Qualität:
1. Installieren Sie ImageMagick
2. Nutzen Sie CONVERT_TO_BMP.ps1
3. ImageMagick rendert SVGs perfekt

### Tipp 2: Batch-Konvertierung

Alle Icons auf einmal:
```powershell
# PowerShell
.\CONVERT_TO_BMP.ps1

# Kopiert automatisch alle 12 Icons
```

### Tipp 3: Eigene Icons

Sie können eigene BMP-Icons erstellen:
- Größe: 64x64 Pixel
- Format: 24-bit BMP
- Benennung: UX.bmp (X = 1-12)
- Pfad: `C:\EdingCNC5.3\icons\op_f_key\user\`

---

## 📞 Hilfe

**Konvertierungs-Scripts:**
- `CONVERT_TO_BMP.ps1` - PowerShell-Konverter
- `convert_to_bmp.py` - Python-Konverter

**Dokumentation:**
- `BMP_CONVERSION_README.md` - Diese Datei
- `icons/ICON_OVERVIEW.md` - Icon-Übersicht
- `INSTALLATION.md` - Installations-Anleitung

---

**Version:** 1.0
**Datum:** 2025-11-27
**Format:** BMP 64x64, 24-bit RGB
