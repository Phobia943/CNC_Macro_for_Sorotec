# CNC Makro für Sorotec Maschinen

Professionelles und anfängerfreundliches CNC-Makro für Sorotec CNC-Maschinen mit Eding 5.3 Steuerung. Dieses Makro bietet umfassende Funktionen für Werkzeugvermessung, Nullpunktsetzung, Tasterfunktionen und mehr.

## 🎯 Features

### Hauptfunktionen

- **User Sub 1: Werkzeuglängenmessung** - Präzise Längenmessung mit Bestätigungsdialog
- **User Sub 2: Z-Nullpunkt setzen** - Einfaches Nullpunktsetzen am Werkstück
- **User Sub 3: Spindelwarmlauf** - Mehrstufiger Warmlauf für längere Spindellebensdauer
- **User Sub 4: Werkzeugwechsel** - Automatisierter Werkzeugwechsel mit optionaler Vermessung
- **User Sub 5: Einzelkantentastung** - Präzises Antasten einzelner Kanten (X+, X-, Y+, Y-)
- **User Sub 6: Zwei-Kanten-Eckentastung** - Nullpunktsetzung mit Rotationsberechnung
- **User Sub 7: Bohrungstastung** - Mittelpunktsermittlung von Bohrungen
- **User Sub 8: Zapfentastung** - Mittelpunktsermittlung von zylindrischen Zapfen
- **User Sub 9: Werkzeugbruchkontrolle** - Verschleißerkennung und Bruchwarnung
- **User Sub 10: Vier-Kanten-Rechteck-Vermessung** - Automatische Messung aller 4 Kanten mit Maßkontrolle (NEU!)
- **User Sub 11: Werkstück-Dicken-Messung** - Präzise Dickenmessung für doppelseitige Bearbeitung (NEU!)
- **User Sub 12: Koordinatensystem-Manager** - Komfortable Verwaltung von G54-G59 Nullpunkten (NEU!)

### Besondere Merkmale

✅ **Tastradius-Kompensation** - Automatische Korrektur in allen Tastroutinen
✅ **Umfassende Sicherheitschecks** - Sensor-Zustandsprüfung, Längenkontrolle, Fehlerbehandlung
✅ **Anfängerfreundlich** - Ausführliche deutsche Kommentare und Dialoge
✅ **Modular aufgebaut** - Leicht erweiterbar und wartbar
✅ **CONFIG-Routine** - Zentrale Konfiguration aller Parameter

## 🔧 Installation

1. **Download der macro.cnc Datei**
   ```bash
   git clone https://github.com/DEIN_USERNAME/CNC_Macro_for_Sorotec.git
   ```

2. **Datei auf die CNC-Steuerung kopieren**
   - Kopiere `macro.cnc` in den Makro-Ordner deiner Eding CNC Steuerung
   - Üblicherweise: `C:\eding\macros\macro.cnc`

3. **Eding CNC neu starten**
   - Starte die Steuerung neu, damit das Makro geladen wird

## ⚙️ Konfiguration

**Wichtig:** Vor der ersten Verwendung muss das Makro konfiguriert werden!

### Erste Konfiguration

Im MDI-Modus eingeben:
```gcode
gosub config
```

Es öffnen sich nacheinander Dialoge für:

1. **Werkzeugwechsler-Typ** (#4520)
   - 0 = Kein automatischer Wechsel
   - 1 = Nur Wechselposition anfahren
   - 2 = Wechselposition + automatische Vermessung

2. **Werkzeuglängensensor** (#4400, #4507, #4508, #4509, etc.)
   - Sensor-Typ (0=Öffner, 1=Schließer)
   - Position X, Y, Z
   - Sicherheitshöhe
   - Vorschubgeschwindigkeiten

3. **Z-Nullpunktsensor** (#4510, #4512, #4513)
   - Tasterhöhe
   - Vorschubgeschwindigkeiten

4. **3D-Taster** (#4546 - **SEHR WICHTIG!**)
   - **Tastradius** (z.B. 1.5 für einen 3mm Tastkugel)
   - Sensor-Typ
   - Vorschubgeschwindigkeiten

5. **Weitere Parameter**
   - Position nach Referenzfahrt
   - Bruchkontrolle-Toleranz
   - Spindelwarmlauf-Parameter

### Kritische Parameter

| Variable | Beschreibung | Beispielwert |
|----------|--------------|--------------|
| #4400 | Werkzeuglängensensor-Typ | 0 (Öffner) |
| #4544 | 3D-Taster Sensor-Typ | 0 (Öffner) |
| **#4546** | **Tastradius (mm)** | **1.5** |
| #4510 | Höhe des Z-Nullpunkttasters | 5.0 |
| #4506 | Sicherheitshöhe Z | -10 |

## 📖 Verwendung

### Grundlegende Funktionen

```gcode
gosub user_1    ; Werkzeuglänge messen
gosub user_2    ; Z-Nullpunkt setzen
gosub user_3    ; Spindel aufwärmen
gosub user_4    ; Werkzeug wechseln
```

### Taster-Funktionen

```gcode
gosub user_5    ; Einzelne Kante antasten (X+, X-, Y+, Y-)
gosub user_6    ; Ecke mit 2 Kanten antasten (inkl. Rotation)
gosub user_7    ; Bohrung antasten (Mittelpunkt finden)
gosub user_8    ; Zapfen antasten (Mittelpunkt finden)
gosub user_9    ; Werkzeugbruchkontrolle
```

### Erweiterte Messfunktionen (NEU in V3.1)

```gcode
gosub user_10   ; Rechteck mit 4 Kanten vermessen (Mittelpunkt + Maßkontrolle)
gosub user_11   ; Werkstück-Dicke messen (Oberseite + Unterseite)
gosub user_12   ; Koordinatensysteme G54-G59 verwalten
```

#### USER_10: Vier-Kanten-Rechteck-Vermessung

Diese Funktion vermisst automatisch alle 4 Kanten eines Rechtecks:

**Funktionen:**
- Misst alle 4 Kanten automatisch (X+, X-, Y+, Y-)
- Berechnet Mittelpunkt des Rechtecks
- Berechnet tatsächliche Länge und Breite
- Vergleicht Ist-Maße mit Soll-Maßen
- Zeigt Abweichungen an
- Setzt Nullpunkt auf Rechteck-Mittelpunkt
- Automatische Kugelradius-Kompensation

**Anwendung:**
1. Taster ungefähr in Rechteck-Mitte positionieren
2. `gosub user_10` aufrufen
3. Soll-Maße eingeben (Länge X, Breite Y)
4. Messung läuft automatisch
5. Ergebnis mit Ist-Soll-Vergleich wird angezeigt

**Parameter:**
- `#4600` - Toleranz für Maßabweichung (Default: 0.1mm)
- `#4601` - Maximale Suchstrecke (Default: 50mm)

#### USER_11: Werkstück-Dicken-Messung

Misst die Dicke eines Werkstücks von Oberseite zu Unterseite:

**Funktionen:**
- Misst Oberseite des Werkstücks
- Misst Unterseite des Werkstücks
- Berechnet tatsächliche Dicke
- Vergleicht mit Soll-Dicke
- Setzt Z-Nullpunkt wahlweise auf Ober- oder Unterseite
- Arbeitet mit Z-Probe oder 3D-Taster
- Wichtig für doppelseitige Bearbeitung

**Anwendung:**
1. `gosub user_11` aufrufen
2. Soll-Dicke eingeben
3. Nullpunkt-Position wählen (0=Oberseite, 1=Unterseite)
4. Sensor-Typ wählen (0=Z-Probe, 1=3D-Taster)
5. Taster über Oberseite positionieren → Messen
6. Taster unter Unterseite positionieren → Messen
7. Ergebnis mit Abweichung wird angezeigt

**Parameter:**
- `#4610` - Toleranz für Dicken-Abweichung (Default: 0.2mm)

**Hinweis:** Werkstück muss so aufgespannt sein, dass die Unterseite zugänglich ist!

#### USER_12: Koordinatensystem-Manager (G54-G59)

Komfortable Verwaltung der Werkstück-Nullpunkte G54-G59:

**Funktionen:**
1. **Speichern**: Aktuellen Nullpunkt in G54-G59 speichern
2. **Laden**: Gespeicherten Nullpunkt aktivieren
3. **Anzeigen**: Alle gespeicherten Koordinatensysteme anzeigen
4. **Löschen**: Koordinatensystem zurücksetzen
5. **Info**: Aktuelle Position anzeigen

**Anwendung:**
1. `gosub user_12` aufrufen
2. Funktion wählen (1-5)
3. Bei Speichern/Laden/Löschen: G5x-Nummer eingeben (54-59)
4. Bestätigen

**Beispiel-Workflow:**
```gcode
; Werkstück 1 antasten und in G54 speichern
gosub user_6         ; Ecke antasten
gosub user_12        ; Koordinatensystem-Manager
; → Funktion 1 (Speichern) wählen
; → G54 wählen

; Werkstück 2 antasten und in G55 speichern
gosub user_6         ; Ecke antasten
gosub user_12        ; Koordinatensystem-Manager
; → Funktion 1 (Speichern) wählen
; → G55 wählen

; Später: G54 aktivieren für Werkstück 1
gosub user_12
; → Funktion 2 (Laden) wählen
; → G54 wählen
```

**Vorteile:**
- Mehrere Werkstücke ohne Neuantasten bearbeiten
- Schneller Wechsel zwischen Werkstücken
- Übersichtliche Anzeige aller gespeicherten Nullpunkte
- Sicheres Löschen mit Bestätigungsabfrage

### Typischer Workflow

1. **Maschine referenzieren**
   ```gcode
   gosub home_all
   ```

2. **Werkzeug einlegen und vermessen**
   ```gcode
   gosub user_1    ; Länge messen
   ```

3. **Werkstück aufspannen und Nullpunkt setzen**
   ```gcode
   gosub user_6    ; Ecke mit 2 Kanten antasten
   gosub user_2    ; Z-Nullpunkt auf Werkstückoberfläche
   ```

4. **Fräsprogramm starten**

## ⚠️ Sicherheitshinweise

🔴 **WICHTIG - Bitte unbedingt beachten:**

1. **Tastradius korrekt einstellen** - Falsche Einstellung führt zu Maßabweichungen!
2. **Sensor vor jedem Einsatz prüfen** - Kabel, Stecker, Funktion
3. **Langsam herantasten** - Beim ersten Mal niedrige Vorschübe wählen
4. **Notaus griffbereit** - Besonders bei ersten Tests
5. **Werkzeuge kontrollieren** - Vor der Vermessung auf Beschädigungen prüfen
6. **Sicherheitshöhe** - Muss höher als das längste Werkzeug sein

### Vor dem ersten Einsatz

- [ ] CONFIG vollständig durchlaufen
- [ ] Tastradius (#4546) korrekt gemessen und eingetragen
- [ ] Sensor-Typ (#4400, #4544) richtig eingestellt
- [ ] Sicherheitshöhe (#4506) ausreichend hoch
- [ ] Werkzeuglängensensor-Position (#4507, #4508) korrekt
- [ ] Testlauf ohne Werkstück durchführen

## 🛠️ Kompatibilität

### Getestet mit:
- **Sorotec Aluline AL1110** mit Eding CNC 5.3
- Weitere Sorotec-Maschinen mit Eding-Steuerung sollten funktionieren

### Voraussetzungen:
- Eding CNC Version 5.3 oder höher
- Werkzeuglängensensor (z.B. Sorotec 3D-Taster)
- Z-Nullpunktsensor oder 3D-Taster

## 📝 Variablen-Übersicht

Eine vollständige Dokumentation aller verwendeten Variablen findest du im Makro selbst (Zeilen 33-168).

**Wichtigste Variablen:**
- **#3500-#3510**: System-Flags und Merker
- **#4400**: Werkzeuglängensensor-Typ
- **#4501-#4509**: Werkzeuglängenmessung
- **#4510-#4513**: Z-Nullpunkt
- **#4544-#4549**: 3D-Taster (inkl. #4546 Tastradius!)
- **#4550-#4566**: Werkstück-Tastung
- **#4600-#4601**: Rechteck-Vermessung (NEU!)
- **#4610**: Dicken-Messung (NEU!)
- **#4620-#4625**: Koordinatensystem-Beschreibungen (reserviert, NEU!)

## 🤝 Beiträge

Verbesserungsvorschläge und Bug-Reports sind willkommen!

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/NeuesFunktion`)
3. Commit deine Änderungen (`git commit -am 'Füge neue Funktion hinzu'`)
4. Push zum Branch (`git push origin feature/NeuesFunktion`)
5. Erstelle einen Pull Request

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE) für Details.

## 📧 Kontakt & Support

Bei Fragen oder Problemen:
- Erstelle ein Issue auf GitHub
- Community-Forum: [Sorotec Forum](https://forum.sorotec.de)

## 🙏 Danksagung

Basierend auf dem Original-Makropaket von Sorotec, weiterentwickelt und optimiert für bessere Benutzerfreundlichkeit und Funktionalität.

---

**Version:** 3.1
**Letzte Aktualisierung:** Januar 2025
**Status:** Produktionsreif

## 📚 Weiterführende Links

- [Eding CNC Dokumentation](https://www.eding.de)
- [Sorotec Website](https://www.sorotec.de)
- [CNC Grundlagen](https://forum.sorotec.de)
