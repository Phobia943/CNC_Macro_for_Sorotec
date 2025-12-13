# CNC Macro Icons - Übersicht

**Erstellt:** 2025-11-27
**Stil:** Minimalistisch modern
**Farbschema:** Sorotec-Branding (Rot #E30613 / Schwarz #1A1A1A)
**Format:** SVG (skalierbar)
**Verwendung:** Eding CNC GUI / Buttons

---

## 📁 User-Funktionen (user_1 bis user_12)

### user_1: Werkzeuglaengenmessung
**Datei:** `user_1_tool_length.svg`
**Beschreibung:** Automatische Messung der Werkzeuglänge mit Tool-Sensor
**Symbol:** Werkzeug über Sensor mit Messpfeilen

### user_2: Z-Nullpunktermittlung
**Datei:** `user_2_z_zero.svg`
**Beschreibung:** Ermittlung des Z-Nullpunkts auf Werkstückoberfläche
**Symbol:** Z-Achse mit Null-Indikator und Werkstück

### user_3: Spindel-Warmlauf
**Datei:** `user_3_spindle_warmup.svg`
**Beschreibung:** 4-stufiger Spindel-Warmlauf für Präzision
**Symbol:** Spindel mit Rotationspfeilen und Hitze-Indikatoren

### user_4: Werkzeugwechsel
**Datei:** `user_4_tool_change.svg`
**Beschreibung:** Manueller Werkzeugwechsel mit Vermessung
**Symbol:** Zwei Werkzeuge mit Austausch-Pfeilen (T1 ↔ T2)

### user_5: Einzelkanten-Antastung
**Datei:** `user_5_edge_probe.svg`
**Beschreibung:** Antastung einzelner Kanten (X+, X-, Y+, Y-) mit Nullpunktsetzung
**Symbol:** Taster und Werkstückkante mit Richtungspfeil

### user_6: Ecken-Antastung mit Rotation
**Datei:** `user_6_corner_rotation.svg`
**Beschreibung:** 2-Punkte-Messung mit Rotationsberechnung und G68-Anwendung
**Symbol:** Rotiertes Werkstück mit Winkelsymbol θ

### user_7: Loch-Antastung
**Datei:** `user_7_hole_probe.svg`
**Beschreibung:** Mittelpunktbestimmung von Löchern (4-Punkt-Messung)
**Symbol:** Loch mit Fadenkreuz und 4 Messpunkten

### user_8: Zylinder/Boss-Antastung
**Datei:** `user_8_cylinder_probe.svg`
**Beschreibung:** Außenmittelpunkt-Bestimmung von Zylindern
**Symbol:** Zylinder mit Mittelpunkt und Radius-Indikator

### user_9: Werkzeug-Bruchkontrolle
**Datei:** `user_9_break_check.svg`
**Beschreibung:** Automatische Prüfung auf Werkzeugbruch
**Symbol:** Gebrochenes Werkzeug mit Warnsymbol ⚠️

### user_10: Rechteck-Vermessung
**Datei:** `user_10_rectangle_measure.svg`
**Beschreibung:** 4-Kanten-Vermessung mit Maßgenauigkeitskontrolle
**Symbol:** Rechteck mit 4 Eckpunkten und Maßpfeilen

### user_11: Werkstück-Dicken-Messung
**Datei:** `user_11_thickness_measure.svg`
**Beschreibung:** Messung der Werkstückdicke für doppelseitige Bearbeitung
**Symbol:** Werkstück mit Ober-/Untermessung und Z-Maß

### user_12: Koordinatensystem-Manager
**Datei:** `user_12_coordinate_manager.svg`
**Beschreibung:** Verwaltung von G54-G59 Koordinatensystemen
**Symbol:** Koordinatenkreuz mit Grid und G-Code-Text

---

## 🔧 Hilfsfunktionen

### config: Konfiguration
**Datei:** `config.svg`
**Beschreibung:** Zugriff auf Konfigurationsmenü
**Symbol:** Zahnrad mit Einstellungs-Kreuz

### home_all: Referenzfahrt
**Datei:** `home_all.svg`
**Beschreibung:** Referenzfahrt aller Achsen (Homing)
**Symbol:** Haus-Symbol mit X/Y/Z-Achsen

### probe_3d: 3D-Taster
**Datei:** `probe_3d.svg`
**Beschreibung:** 3D-Taster Indikator/Status
**Symbol:** Taster mit Rubinkugel und 3D-Richtungen

### sensor_check: Sensor-Prüfung
**Datei:** `sensor_check.svg`
**Beschreibung:** Sensor-Verbindung und Status prüfen
**Symbol:** Sensor mit Checkmark und LED-Indikator

### handwheel: Handrad
**Datei:** `handwheel.svg`
**Beschreibung:** Handrad-Controller Integration (XHC)
**Symbol:** Handrad mit Display und Buttons

### emergency_stop: Not-Stopp
**Datei:** `emergency_stop.svg`
**Beschreibung:** Not-Aus / Stopp-Funktion
**Symbol:** Rotes Achteck mit "STOP"

---

## 📐 Technische Spezifikationen

### SVG-Eigenschaften
- **Viewbox:** 64x64
- **Optimiert für:** 32px, 48px, 64px, 128px Darstellung
- **Linienstärke:** 2px (skaliert proportional)
- **Farben:**
  - Primär (Rot): `#E30613` (Sorotec-Rot)
  - Sekundär (Schwarz): `#1A1A1A` (Fast-Schwarz)
  - Stroke: `#1A1A1A`, 2px

### CSS-Klassen (in jedem SVG definiert)
```css
.primary { fill: #E30613; }
.secondary { fill: #1A1A1A; }
.stroke { stroke: #1A1A1A; stroke-width: 2; fill: none; }
```

---

## 🖼️ PNG-Konvertierung

Die Icons wurden als **SVG-Vektorgrafiken** erstellt. Um PNG-Versionen zu generieren:

### Option 1: Online-Konverter
- https://cloudconvert.com/svg-to-png
- https://convertio.co/svg-png/
- https://svgtopng.com/

### Option 2: Inkscape (Desktop)
```bash
inkscape --export-type=png --export-width=64 --export-filename=user_1_tool_length.png user_1_tool_length.svg
```

### Option 3: ImageMagick
```bash
convert -background none -resize 64x64 user_1_tool_length.svg user_1_tool_length.png
```

### Option 4: rsvg-convert
```bash
rsvg-convert -w 64 -h 64 user_1_tool_length.svg -o user_1_tool_length.png
```

### Empfohlene PNG-Größen
- **32x32:** Kleine Buttons, Toolbar
- **64x64:** Standard-Buttons
- **128x128:** Große Schaltflächen, Touch-Interfaces
- **256x256:** Hochauflösende Displays, Dokumentation

---

## 🎨 Anpassung der Farben

Um die Farben anzupassen, editieren Sie in jedem SVG die `<style>` Sektion:

```xml
<defs>
  <style>
    .primary { fill: #E30613; }      <!-- Ihre Primärfarbe -->
    .secondary { fill: #1A1A1A; }    <!-- Ihre Sekundärfarbe -->
    .stroke { stroke: #1A1A1A; stroke-width: 2; fill: none; }
  </style>
</defs>
```

### Beispiel-Farbschemata

**Grün/Schwarz (Standard CNC):**
```css
.primary { fill: #00AA00; }
.secondary { fill: #1A1A1A; }
```

**Blau/Grau (Modern):**
```css
.primary { fill: #0066CC; }
.secondary { fill: #333333; }
```

**Orange/Schwarz (Warnung):**
```css
.primary { fill: #FF6600; }
.secondary { fill: #000000; }
```

---

## 📦 Verwendung in Eding CNC

### In HTML/GUI einbinden
```html
<!-- Direkt als IMG -->
<img src="icons/user_1_tool_length.svg" width="64" height="64" alt="Werkzeuglänge messen">

<!-- Als Button-Icon -->
<button class="macro-button">
  <img src="icons/user_1_tool_length.svg" width="48" height="48">
  <span>Werkzeuglänge messen</span>
</button>

<!-- Inline SVG (für CSS-Styling) -->
<div class="icon" style="background-image: url('icons/user_1_tool_length.svg')"></div>
```

### Button-Style Beispiel
```css
.macro-button {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  background: #f5f5f5;
  border: 2px solid #ddd;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.macro-button:hover {
  background: #E30613;
  color: white;
  border-color: #E30613;
}

.macro-button img {
  margin-right: 12px;
}
```

---

## 📄 Lizenz

Diese Icons wurden speziell für das **Sorotec Eding CNC Macro V3.6** erstellt.

**Nutzungsbedingungen:**
- ✅ Frei verwendbar für CNC-Projekte
- ✅ Anpassung und Modifikation erlaubt
- ✅ Kommerzielle Nutzung erlaubt
- ✅ Weitergabe mit Namensnennung

**Namensnennung:**
```
Icons erstellt für Sorotec Eding CNC Macro V3.6
Design: Minimalistisch modern, Sorotec-Branding
```

---

## 🚀 Nächste Schritte

1. **Icons testen:** Öffnen Sie die SVG-Dateien in einem Browser
2. **PNG generieren:** Nutzen Sie eine der oben genannten Methoden
3. **In GUI integrieren:** Binden Sie die Icons in Ihr Eding CNC Interface ein
4. **Anpassen:** Passen Sie Farben nach Bedarf an
5. **Feedback:** Berichten Sie von Ihrer Erfahrung

---

## 📞 Support

Bei Fragen oder Anpassungswünschen:
- Siehe Hauptdokumentation: `README.md`
- Icon-Vorschau: `ICON_PREVIEW.html` (öffnen im Browser)

**Version:** 1.0
**Datum:** 2025-11-27
**Icons gesamt:** 18 (12 User + 6 Hilfs-Funktionen)
