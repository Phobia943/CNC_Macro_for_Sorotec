# 🎨 CNC Macro Icons

**18 professionelle SVG-Icons** für Sorotec Eding CNC V3.6

## 🚀 Schnellstart

1. **Icons ansehen:** Öffnen Sie `ICON_PREVIEW.html` im Browser
2. **Details lesen:** Siehe `ICON_OVERVIEW.md`
3. **PNG erstellen:** Siehe `PNG_CONVERT.md`

## 📦 Inhalt

- **12 User-Funktionen** (user_1 bis user_12)
- **6 Hilfsfunktionen** (config, home_all, probe_3d, sensor_check, handwheel, emergency_stop)

## 🎨 Design

- **Stil:** Minimalistisch modern
- **Farben:** Sorotec-Branding (Rot #E30613, Schwarz #1A1A1A)
- **Format:** SVG (skalierbar, 64x64 viewbox)
- **Dateigröße:** ~1 KB pro Icon

## 📖 Dokumentation

| Datei | Beschreibung |
|-------|--------------|
| `ICON_PREVIEW.html` | 🖼️ Visuelle Vorschau aller Icons (Browser öffnen!) |
| `ICON_OVERVIEW.md` | 📋 Vollständige Icon-Dokumentation |
| `PNG_CONVERT.md` | 🔄 Anleitung zur PNG-Konvertierung |
| `README.md` | 📄 Diese Datei |

## 🔥 Highlights

✅ Vektorgrafiken - perfekt skalierbar
✅ Transparenter Hintergrund
✅ Sorotec-Farben
✅ Moderne, klare Symbolik
✅ Optimiert für CNC-GUI

## 💡 Verwendung

```html
<!-- In HTML -->
<img src="icons/user_1_tool_length.svg" width="64" height="64" alt="Werkzeuglänge">

<!-- Als Button -->
<button>
  <img src="icons/user_1_tool_length.svg" width="48" height="48">
  Werkzeuglänge messen
</button>
```

## 🎯 Alle Icons

### User-Funktionen
1. `user_1_tool_length.svg` - Werkzeuglängenmessung
2. `user_2_z_zero.svg` - Z-Nullpunktermittlung
3. `user_3_spindle_warmup.svg` - Spindel-Warmlauf
4. `user_4_tool_change.svg` - Werkzeugwechsel
5. `user_5_edge_probe.svg` - Einzelkanten-Antastung
6. `user_6_corner_rotation.svg` - Ecken-Antastung mit Rotation
7. `user_7_hole_probe.svg` - Loch-Antastung
8. `user_8_cylinder_probe.svg` - Zylinder-Antastung
9. `user_9_break_check.svg` - Werkzeug-Bruchkontrolle
10. `user_10_rectangle_measure.svg` - Rechteck-Vermessung
11. `user_11_thickness_measure.svg` - Dicken-Messung
12. `user_12_coordinate_manager.svg` - Koordinatensystem-Manager

### Hilfsfunktionen
- `config.svg` - Konfiguration
- `home_all.svg` - Referenzfahrt
- `probe_3d.svg` - 3D-Taster
- `sensor_check.svg` - Sensor-Prüfung
- `handwheel.svg` - Handrad (XHC)
- `emergency_stop.svg` - Not-Stopp

## 🔄 PNG-Versionen erstellen

**Einfachste Methode:** Online-Konverter
- https://cloudconvert.com/svg-to-png
- Alle SVGs hochladen → Größe wählen → Convert

**Erweiterte Methoden:** Siehe `PNG_CONVERT.md`

## 📐 Empfohlene Größen

- 32x32 - Kleine Buttons, Toolbar
- 64x64 - Standard-Buttons
- 128x128 - Große Buttons, Touch-Interfaces

## 🎨 Farben anpassen

Icons nutzen CSS-Klassen. Einfach in jedem SVG die Farben ändern:

```xml
<style>
  .primary { fill: #E30613; }      <!-- Ihre Farbe -->
  .secondary { fill: #1A1A1A; }    <!-- Ihre Farbe -->
</style>
```

## 📊 Statistik

- **Gesamt:** 18 SVG-Icons
- **Durchschnittliche Größe:** 1.1 KB
- **Gesamtgröße:** ~21 KB
- **Format:** SVG 1.1 (kompatibel mit allen Browsern)

## ✨ Features

- ✅ Retina/HiDPI-ready
- ✅ Transparenter Hintergrund
- ✅ Keine externe Abhängigkeiten
- ✅ Cross-Browser kompatibel
- ✅ Druckoptimiert
- ✅ Barrierearm (mit alt-Texten)

## 📞 Support

Siehe Haupt-Dokumentation: `../README.md`

---

**Version:** 1.0
**Erstellt:** 2025-11-27
**Lizenz:** Frei verwendbar für CNC-Projekte
