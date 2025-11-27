# ⚙️ Konfigurationsanleitung - Sorotec Eding CNC Macro

**Version:** 3.6
**Datum:** 2025-11-27

---

## 🚀 Schnellstart

### Konfiguration starten:

1. **Öffnen Sie Eding CNC**
2. **Wechseln Sie in den MDI-Modus** (Manual Data Input)
3. **Geben Sie ein:**
   ```
   gosub config
   ```
4. **Drücken Sie ENTER**

---

## 📋 Konfigurationsmenü-Struktur

Die Konfiguration führt Sie durch **5 Bereiche**:

```
gosub config
    ↓
    ├── 1. Werkzeugwechsel-Parameter
    ├── 2. Z-Nullpunkt-Parameter
    ├── 3. Werkzeuglängenmessung-Parameter ⭐
    ├── 4. 3D-Taster-Parameter
    └── 5. Spindel-Warmlauf-Parameter
```

---

## 🔧 1. Werkzeugwechsel-Parameter

### Parameter:

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Typ** | #4520 | Werkzeugwechsel-Modus | 0=Aus, 1=Nur Position, 2=Position+Messen |
| **Position X** | #4521 | X-Position für Werkzeugwechsel | z.B. -500 mm |
| **Position Y** | #4522 | Y-Position für Werkzeugwechsel | z.B. 0 mm |
| **Position Z** | #4523 | Z-Position für Werkzeugwechsel | z.B. -5 mm (sicher) |

### Empfehlung:
```
Typ:        0  (wenn kein automatischer Wechsler)
            1  (wenn feste Wechselposition)
            2  (wenn mit automatischer Vermessung)
```

---

## 🎯 2. Z-Nullpunkt-Parameter

### Parameter:

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Sensor-Typ** | #4400 | Typ des Z-Sensors | 0=Öffner (NC), 1=Schließer (NO) |
| **Tasterhöhe** | #4510 | Höhe des Z-Sensors in mm | z.B. 50.00 mm |
| **Anfahrvorschub** | #4512 | Schnell-Vorschub in mm/min | z.B. 1000 mm/min |
| **Tastvorschub** | #4513 | Mess-Vorschub in mm/min | z.B. 50 mm/min |

### Sorotec Standardwerte:
```
Sensor-Typ:      1  (Schließer - bei den meisten Sorotec 3D-Tastern)
Tasterhöhe:      50.00 mm  (je nach Taster messen!)
Anfahrvorschub:  1000 mm/min
Tastvorschub:    50 mm/min
```

---

## 📏 3. Werkzeuglängenmessung-Parameter ⭐

### A) Position nach Referenzfahrt

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Position X** | #4631 | X nach Referenzfahrt | z.B. 0 mm |
| **Position Y** | #4632 | Y nach Referenzfahrt | z.B. 0 mm |
| **Position Z** | #4633 | Z nach Referenzfahrt | z.B. -5 mm (sicher) |

### B) Werkzeuglängensensor-Konfiguration

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Position X** | #4507 | X-Position des Längensensors | z.B. 100 mm |
| **Position Y** | #4508 | Y-Position des Längensensors | z.B. 100 mm |
| **Sicherheitshöhe Z** | #4506 | Max. sichere Z-Höhe | z.B. -5 mm ⭐ |
| **Spindelnase bei Z0** | #4509 | Abstand Spindelnase zu Sensor bei Z=0 | z.B. 120 mm |
| **Max. Werkzeuglänge** | #4503 | Längste erlaubte Werkzeuglänge | z.B. 150 mm ⭐ |
| **Anfahrvorschub** | #4504 | Schnell-Vorschub | z.B. 1500 mm/min |
| **Tastvorschub** | #4505 | Mess-Vorschub | z.B. 100 mm/min |

#### ⭐ Wichtig: Maximale Werkzeuglänge berechnen

**Formel:**
```
Max. WZ-Länge = Sicherheitshöhe Z + Spindelnase bei Z0 - Mindestabstand

Beispiel:
-5 mm (Sicherheitshöhe) + 120 mm (Spindelnase) - 10 mm (Reserve) = 105 mm
```

**Empfehlung für Sorotec Aluline AL1110:**
```
Position X:         100 mm   (Position des Längensensors auf Tisch)
Position Y:         100 mm
Sicherheitshöhe Z:  -5 mm    (sichere Höhe über Tisch)
Spindelnase bei Z0: 120 mm   (MESSEN! Abhängig von Ihrer Maschine)
Max. Werkzeuglänge: 150 mm   (oder kleiner je nach Bedarf)
Anfahrvorschub:     1500 mm/min
Tastvorschub:       100 mm/min
```

### C) Bruchkontrolle

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Aktivieren** | #4529 | Bruchkontrolle ein/aus | 0=Aus, 1=An |
| **Verschleißtoleranz** | #4528 | Erlaubte Abweichung +/- | z.B. 0.02 mm |

### D) Position nach Werkzeugmessung

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Funktion** | #4519 | Was nach Messung tun | 0-4 (siehe unten) |
| **Position X** | #4524 | Ziel-X nach Messung | z.B. 0 mm |
| **Position Y** | #4525 | Ziel-Y nach Messung | z.B. 0 mm |

**Funktionen nach Messung:**
```
0 = An aktueller Position bleiben
1 = Zu Referenzposition fahren
2 = Zu spezifischer Position fahren (X/Y)
3 = Zu Werkstück-Nullpunkt fahren
4 = Zurück zur Ausgangsposition
```

---

## 🎯 4. 3D-Taster-Parameter

### A) Grundparameter

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Sensor-Typ** | #4544 | Typ des 3D-Tasters | 0=Öffner, 1=Schließer |
| **Tasterlänge** | #4545 | Länge des Tasters als Werkzeug | z.B. 50.00 mm |
| **Kugelradius** | #4546 | Radius der Tastkugel ⭐ WICHTIG! | z.B. 2.00 mm |
| **Anfahrvorschub** | #4548 | Schnell-Vorschub | z.B. 1000 mm/min |
| **Tastvorschub** | #4549 | Mess-Vorschub | z.B. 50 mm/min |

#### ⭐ WICHTIG: Kugelradius richtig messen!

Der Kugelradius ist entscheidend für korrekte Messungen!

**Messung:**
1. Tastkugel-Durchmesser messen (z.B. mit Messschieber)
2. Durch 2 teilen = Radius
3. Beispiel: Durchmesser 4 mm → Radius 2 mm

### B) Versatz-Werte

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Versatz X+** | #4551 | Korrektur X+ Richtung | Meist 0.00 mm |
| **Versatz X-** | #4552 | Korrektur X- Richtung | Meist 0.00 mm |
| **Versatz Y+** | #4553 | Korrektur Y+ Richtung | Meist 0.00 mm |
| **Versatz Y-** | #4554 | Korrektur Y- Richtung | Meist 0.00 mm |

**Hinweis:** Diese Werte werden für Einzelkanten-Antastung automatisch auf 0 gesetzt.

### C) Spindelversatz

| Parameter | Variable | Beschreibung | Typische Werte |
|-----------|----------|--------------|----------------|
| **Versatz aktiv** | #4560 | Versatz berücksichtigen? | 0=Nein, 1=Ja |
| **Versatz X** | #4561 | X-Versatz zur Spindelmitte | z.B. 0.00 mm |
| **Versatz Y** | #4562 | Y-Versatz zur Spindelmitte | z.B. 0.00 mm |

**Nur nötig wenn:** Taster nicht genau in Spindelmitte sitzt.

---

## 🔥 5. Spindel-Warmlauf-Parameter

### Parameter (4 Stufen):

| Stufe | Drehzahl | Variable | Laufzeit | Variable |
|-------|----------|----------|----------|----------|
| **Stufe 1** | z.B. 3000 RPM | #4532 | z.B. 120 s | #4533 |
| **Stufe 2** | z.B. 8000 RPM | #4534 | z.B. 120 s | #4535 |
| **Stufe 3** | z.B. 12000 RPM | #4536 | z.B. 120 s | #4537 |
| **Stufe 4** | z.B. 18000 RPM | #4538 | z.B. 180 s | #4539 |

### Empfohlene Werte für Sorotec Spindel:

```
Stufe 1:  3000 RPM  / 120 Sekunden  (Langsam starten)
Stufe 2:  8000 RPM  / 120 Sekunden  (Mittlere Drehzahl)
Stufe 3: 12000 RPM  / 120 Sekunden  (Höhere Drehzahl)
Stufe 4: 18000 RPM  / 180 Sekunden  (Max. Drehzahl länger)

Gesamt-Zeit: ~9 Minuten
```

---

## 📝 Beispiel-Konfiguration

### Für Sorotec Aluline AL1110 mit 3D-Taster:

```
=== WERKZEUGWECHSEL ===
Typ:                    0  (manuell)

=== Z-NULLPUNKT ===
Sensor-Typ:             1  (Schließer)
Tasterhöhe:             50.00 mm
Anfahrvorschub:         1000 mm/min
Tastvorschub:           50 mm/min

=== WERKZEUGLÄNGENMESSUNG ===
Position nach Referenz:
  X: 0 mm, Y: 0 mm, Z: -5 mm

Längensensor:
  Position X:           100 mm
  Position Y:           100 mm
  Sicherheitshöhe Z:    -5 mm
  Spindelnase bei Z0:   120 mm
  Max. Werkzeuglänge:   150 mm  ⭐
  Anfahrvorschub:       1500 mm/min
  Tastvorschub:         100 mm/min

Bruchkontrolle:
  Aktivieren:           1  (An)
  Verschleißtoleranz:   0.02 mm

Position nach Messung:
  Funktion:             1  (Referenzposition)

=== 3D-TASTER ===
Sensor-Typ:             1  (Schließer)
Tasterlänge:            50.00 mm
Kugelradius:            2.00 mm  ⭐ WICHTIG!
Anfahrvorschub:         1000 mm/min
Tastvorschub:           50 mm/min

Versatz-Werte:          Alle 0.00 mm

Spindelversatz:
  Aktiv:                0  (Nein)

=== SPINDEL-WARMLAUF ===
Stufe 1:  3000 RPM  / 120 s
Stufe 2:  8000 RPM  / 120 s
Stufe 3: 12000 RPM  / 120 s
Stufe 4: 18000 RPM  / 180 s
```

---

## 🔍 Konfiguration überprüfen

### Methode 1: Im MDI-Modus Variable abfragen

```
MDI-Eingabe: #4503
→ Zeigt aktuelle max. Werkzeuglänge an

MDI-Eingabe: #4546
→ Zeigt aktuellen Kugelradius an
```

### Methode 2: Variablen-Liste in Eding CNC

1. Menü → Variablen
2. Suchen Sie nach #45xx oder #46xx
3. Zeigt alle konfigurierten Werte

---

## ⚙️ Manuelle Konfiguration (für Experten)

Falls Sie Parameter direkt setzen möchten (im MDI):

```gcode
; Maximale Werkzeuglänge auf 150 mm setzen:
#4503 = 150

; Kugelradius auf 2 mm setzen:
#4546 = 2

; Tastvorschub auf 100 mm/min setzen:
#4505 = 100
```

**WICHTIG:** Änderungen werden sofort aktiv!

---

## 📊 Variablen-Übersicht

### Wichtigste Variablen:

| Variable | Parameter | Standard |
|----------|-----------|----------|
| **#4503** | Max. Werkzeuglänge | 150 mm |
| **#4506** | Sicherheitshöhe Z | -5 mm |
| **#4509** | Spindelnase bei Z0 | 120 mm |
| **#4546** | 3D-Taster Kugelradius | 2 mm |
| **#4529** | Bruchkontrolle aktiv | 1 |
| **#4528** | Verschleißtoleranz | 0.02 mm |

### Alle Variablen (#45xx - #46xx):

Siehe Datei: **VARIABLE_REFERENCE.md** (vollständige Liste)

---

## ⚠️ Häufige Fehler

### Fehler 1: "Werkzeug zu lang für Maschine"

**Ursache:** Werkzeuglänge überschreitet Max. Werkzeuglänge (#4503)

**Lösung:**
```
1. gosub config aufrufen
2. Werkzeuglängenmessung-Parameter öffnen
3. Max. Werkzeuglänge erhöhen (z.B. auf 200 mm)
4. ODER kürzeres Werkzeug verwenden
```

### Fehler 2: "Sensor nicht gefunden"

**Ursache:** Sensor-Position falsch oder Sensor defekt

**Lösung:**
```
1. Prüfen Sie Sensor-Position (#4507, #4508)
2. Prüfen Sie Sensor-Typ (#4400 oder #4544)
3. Prüfen Sie Kabelverbindung
4. Testen Sie Sensor manuell (Spindelabsenkung)
```

### Fehler 3: Falsche Messungen mit 3D-Taster

**Ursache:** Kugelradius falsch konfiguriert

**Lösung:**
```
1. gosub config aufrufen
2. 3D-Taster-Parameter öffnen
3. Kugelradius exakt messen und eingeben
4. Beispiel: Kugel-Durchmesser 4 mm → Radius 2 mm
```

---

## 💾 Konfiguration speichern

**Die Konfiguration wird automatisch gespeichert!**

- Alle Parameter werden in Eding CNC System-Variablen gespeichert
- Bleiben nach Neustart erhalten
- Werden mit Maschinendaten gesichert

### Backup erstellen:

```
1. Eding CNC → Menü → Einstellungen → Variablen exportieren
2. Speichern als: "CNC_Config_Backup_DATUM.var"
3. Bei Bedarf wiederherstellen
```

---

## 🎯 Erste Schritte nach Konfiguration

1. **gosub config** im MDI ausführen
2. **Alle 5 Bereiche** durchgehen und konfigurieren
3. **Werkzeuglaengenmessung testen** (user_1)
4. **Z-Nullpunkt testen** (user_2)
5. **3D-Taster testen** mit Einzelkante (user_5)

---

## 📞 Support

Bei Fragen zur Konfiguration:

1. Siehe: **README.md** (Haupt-Dokumentation)
2. Siehe: **INSTALLATION.md** (Setup-Anleitung)
3. GitHub Issues erstellen

---

**Version:** 3.6
**Datum:** 2025-11-27
**Für:** Sorotec Eding CNC 5.3
