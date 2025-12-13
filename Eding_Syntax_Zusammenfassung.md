# Eding CNC 5.3 - Syntax-Referenz

**Basis:** Eding_Handbuch.pdf (69 Seiten)
**Analysedatum:** 14. November 2025
**Zweck:** Referenz für Code-Korrektur und Macro-Entwicklung

---

## 1. VARIABLEN-SYSTEM

### Bereiche und Verwendung

```
#1-#26          Parameter A-Z (bei M-Code/Subroutine-Aufruf)
#27-#4999       Frei verwendbar
#4000-#4999     Persistent gespeichert
#5001-#5999     System-Variablen (meist READ-ONLY)
```

### Wichtige System-Variablen

| Variable | Bedeutung | Zugriff |
|----------|-----------|---------|
| **#5001-#5006** | Aktuelle Position X, Y, Z, A, B, C (Arbeitskoordinaten) | READ |
| **#5008** | Aktuelle Werkzeugnummer | READ |
| **#5009** | Aktueller Werkzeugradius | READ |
| **#5010** | Aktueller Tool Z-Offset (Länge + Verschleiß) | READ |
| **#5051-#5056** | Sondenposition X-C (Maschinenkoordinaten) | READ |
| **#5061-#5066** | Sondenposition X-C (Arbeitskoordinaten) | READ |
| **#5067** | Sonde ausgelöst nach G38.2 (1=ja, 0=nein) | READ |
| **#5220** | Aktives Koordinatensystem (1=G54...9=G59.3) | READ |
| **#5380** | Simulationsmodus (0=normal, 1=Simulation) | READ |
| **#5397** | Render-Modus (0=normal, 1=Render) | READ |
| **#5398** | Rückgabewert dlgmsg (+1=OK, -1=Cancel) | READ |
| **#5399** | Rückgabewert M55/M56 (I/O) | READ |
| **#5401-#5499** | Werkzeug Z-Offset (Länge), Tool 1-99 | READ/WRITE |
| **#5501-#5599** | Werkzeugdurchmesser, Tool 1-99 | READ/WRITE |
| **#5801-#5899** | Werkzeug X Delta (Verschleiß) | READ/WRITE |
| **#5901-#5999** | Werkzeug Z Delta (Verschleiß) | READ/WRITE |

### Syntax-Regeln

```gcode
#50 = 100           ; Einfache Zuweisung
#50 = [#1 + #2]     ; Mit Ausdruck
##2                 ; Indirekte Adressierung (Wert von Parameter 2 als Index)
```

**KRITISCH:** Das #-Zeichen hat Vorrang!
- `#1 + 2` = Wert von #1, plus 2
- `#[1+2]` = Wert von #3

**Parameter-Timing:**
- Parametereinstellungen werden erst NACH Auswertung der gesamten Zeile wirksam!
```gcode
#1 = 10
G0 X#1    ; Verwendet ALTEN Wert von #1, DANN wird #1 auf 10 gesetzt!
```

---

## 2. AUSDRÜCKE UND OPERATOREN

### Grundregel

**IMMER eckige Klammern verwenden:**
```gcode
G0 X[10 + 5]        ; RICHTIG - X=15
G0 X10 + 5          ; FALSCH - wird als X10 interpretiert
```

### Operatoren (Priorität absteigend)

1. **Potenz:** `**`
2. **Multiplikation/Division:** `*` `/` `MOD`
3. **Addition/Subtraktion/Logik:** `+` `-` `OR` `XOR` `AND`

### Vergleichsoperatoren

```gcode
==    Gleich
!=    Ungleich
<     Kleiner
>     Größer
<=    Kleiner gleich
>=    Größer gleich
```

### Mathematische Funktionen

```gcode
ABS[x]          Absolutwert
SQRT[x]         Quadratwurzel
EXP[x]          e^x
LN[x]           Natürlicher Logarithmus

SIN[x]          Sinus (x in Grad!)
COS[x]          Cosinus (x in Grad!)
TAN[x]          Tangens (x in Grad!)
ASIN[x]         Arcsin (Ergebnis in Grad)
ACOS[x]         Arccos (Ergebnis in Grad)
ATAN[y]/[x]     Arctan (Ergebnis in Grad)

FIX[x]          Abrunden zur negativen Seite
FUP[x]          Aufrunden zur positiven Seite
ROUND[x]        Runden zur nächsten Ganzzahl
```

**Beispiele:**
```gcode
FIX[2.8] = 2      FIX[-2.8] = -3
FUP[2.8] = 3      FUP[-2.8] = -2
ROUND[2.4] = 2    ROUND[2.6] = 3
```

---

## 3. G38.2 PROBING - KRITISCHE REGELN

### Syntax

```gcode
G38.2 X... Y... Z... [F...]
```

### Anforderungen

**ZWINGEND:**
- Mindestens EIN Achswort (X, Y oder Z)
- Vorschub F muss gesetzt sein (modal oder in Zeile)
- NICHT in G93-Modus (inverse Zeit)

### Fehlerprüfung

```gcode
; IMMER Simulation/Render-Check!
IF [[#5380 == 0] AND [#5397 == 0]]
  G38.2 Z-10 F100

  IF [#5067 == 1]
    ; Sonde ausgelöst - Position in #5061-#5066
    MSG "Z-Position: " #5063
  ELSE
    ERRMSG "Sonde nicht ausgelöst!"
  ENDIF
ENDIF
```

### G38.2 mit G53 (Maschinenkoordinaten)

```gcode
G53 G38.2 Z#4999 F100    ; Messen in absoluten Koordinaten
```

**WICHTIG:** G53 ist NICHT modal - muss in jeder Zeile stehen!

---

## 4. MODALE GRUPPEN

### Regel: Nur EIN G-Code pro Gruppe pro Zeile!

| Gruppe | G-Codes | Bedeutung |
|--------|---------|-----------|
| **1** | G0, G1, G2, G3, G38.2, G76, G80-G89 | Bewegung |
| **2** | G17, G18, G19 | Ebenenauswahl |
| **3** | G90, G91 | Distanzmodus |
| **5** | G93, G94, G95 | Vorschubmodus |
| **6** | G20, G21 | Einheiten |
| **7** | G40, G41, G42 | Fräserradiuskorrektur |
| **8** | G43, G49 | Werkzeuglängenversatz |
| **10** | G98, G99 | Rückzugsmodus |
| **12** | G54-G59.3 | Koordinatensystem |
| **14** | G68, G69 | XY-Rotation |
| **0** | G4, G10, G28, G30, G53, G92.x | Nicht-modal |

**Häufiger Fehler:**
```gcode
G0 G28 X10    ; FEHLER - beide nutzen Achswörter
G28 X10       ; RICHTIG
```

---

## 5. KOORDINATENSYSTEME

### Hierarchie (von innen nach außen)

1. **Maschinenkoordinaten** (absolut, unveränderlich)
2. **G54-G59.3 Offsets** (9 Systeme)
3. **G92 Offset** (gilt für ALLE 9 Systeme)

### G10 L2 - Koordinatensystem setzen

```gcode
G10 L2 P1 X10 Y20 Z5    ; Setzt G54-Ursprung (P1=G54...P9=G59.3)
```

### G10 L20 - Aktuellen Punkt als Nullpunkt

```gcode
G10 L20 P1 X0 Y0        ; Aktueller Punkt wird zu (0,0) in G54
```

### G92 - Offset setzen

```gcode
G92 X0 Y0 Z10           ; Aktueller Punkt wird zu (0, 0, 10)
```

**WARNUNG:** G92 akkumuliert! Vor erneutem Setzen:
```gcode
G92.1                   ; Reset G92-Offset
```

### G53 - Maschinenkoordinaten

```gcode
G53 G0 Z0               ; Fährt zu Z=0 in Maschinenkoordinaten
G53 G0 X100 Y50         ; NICHT modal - muss jede Zeile stehen!
```

**FEHLER wenn:**
- Fräserradiuskorrektur (G41/G42) aktiv ist
- Nicht mit G0 oder G1 kombiniert

---

## 6. VORSCHUBMODI

### G94 - Einheiten pro Minute (Standard)

```gcode
G94
F1000                   ; 1000 mm/min oder inch/min
```

### G93 - Inverse Zeit

```gcode
G93
G1 X100 F6              ; Bewegung dauert 1/6 min = 10 Sekunden
```

**KRITISCH:** F muss in JEDER Bewegungszeile angegeben werden!

### G95 - Einheiten pro Umdrehung

```gcode
G95
F0.2 S1000              ; 0.2mm pro Umdrehung = 200 mm/min bei 1000 RPM
```

---

## 7. WERKZEUGVERWALTUNG

### Werkzeuglängenversatz

```gcode
G43             ; Offset des aktuellen Werkzeugs
G43 H5          ; Offset von Werkzeug 5
G43.1 K-50      ; Dynamischer Offset (-50mm in Z)
G49             ; Versatz aufheben
```

### Werkzeugwechsel

```gcode
T5              ; Werkzeug 5 auswählen
M6              ; Wechsel durchführen (ruft Subroutine in macro.cnc)
```

### Direkter Zugriff auf Werkzeugdaten

```gcode
#5401           ; Z-Offset (Länge) von Tool 1
#5501           ; Durchmesser von Tool 1
#5601           ; X-Offset von Tool 1 (Drehen)

; Verschleiß zur Laufzeit anpassen:
#5401 = [#5401 - 0.05]    ; 0.05mm Verschleiß für Tool 1
```

---

## 8. FRÄSERRADIUSKORREKTUR

### Aktivierung

```gcode
G41 D5          ; Links, Werkzeug 5
G42 D5          ; Rechts, Werkzeug 5
G41.1 D6        ; Links, D=Durchmesser (nicht Tool-Nummer!)
G40             ; Korrektur aus
```

### Eintrittsbewegung (PFLICHT!)

```gcode
G42.1 D6
G1 X-5          ; Eintrittslinie (>Radius, hier >3mm)
G2 X0 Y10 R5    ; Eintrittsbogen (R>Werkzeugradius)
G1 Z-3 F500     ; Jetzt eintauchen
```

---

## 9. FESTZYKLEN

### G81 - Bohren

```gcode
G81 X10 Y20 Z-5 R2 F100
```

**Parameter:**
- X, Y: Bohrposition
- Z: Bohrtiefe
- R: Rückzugshöhe (muss > Z sein!)
- F: Vorschub

### G83 - Peck-Bohren

```gcode
G83 X10 Y20 Z-20 R2 Q5 F100
```

**Q:** Delta-Tiefe pro Zyklus (muss > 0 sein!)

### G84 / G74 - Gewindebohren

```gcode
M3 S1000
G84 X10 Y20 Z-15 R2 F1.5    ; Rechtsgewinde
```

```gcode
M4 S1000
G74 X10 Y20 Z-15 R2 F1.5    ; Linksgewinde
```

**KRITISCH:** Spindel MUSS laufen! Dreht automatisch nach Erreichen von Z um.

### G98 / G99 - Rückzugsmodus

```gcode
G98             ; Rückzug zur Startposition (Standard)
G99             ; Rückzug zu R-Ebene
```

---

## 10. M-CODES

### Spindelsteuerung

```gcode
S1000           ; Drehzahl setzen
M3              ; Spindel im Uhrzeigersinn
M4              ; Spindel gegen Uhrzeigersinn
M5              ; Spindel stopp
```

### Kühlmittel

```gcode
M7              ; Nebelkühlmittel
M8              ; Flutkühlmittel
M9              ; Kühlmittel aus
```

**Besonderheit:** M7 und M8 können gleichzeitig aktiv sein!

### I/O-Steuerung (M54-M57)

**M54 - Ausgang setzen:**
```gcode
M54 P1                  ; AUX1 auf HIGH
M54 E2 Q500             ; PWM2 auf 50% (Q in Promille!)
```

**M55 - Ausgang löschen:**
```gcode
M55 P1                  ; AUX1 auf LOW
```

**M56 - Eingang lesen:**
```gcode
M56 P3                  ; Eingang 3 lesen
IF [#5399 == 1]
  MSG "AUX3 ist HIGH"
ENDIF
```

**M56 mit Timeout:**
```gcode
M56 P3 L1 Q30           ; Warte max. 30s auf HIGH
IF [#5399 == -1]
  ERRMSG "Timeout!"
ENDIF
```

**L-Parameter:**
- L0: Nicht warten
- L1: Warten auf HIGH
- L2: Warten auf LOW

**M57 - Ausgang lesen:**
```gcode
M57 P1                  ; Digital-Ausgang 1
M57 E2                  ; PWM-Ausgang 2
; Ergebnis in #5399
```

---

## 11. SUBROUTINEN

### Definition

```gcode
SUB meine_routine
  MSG "X=" #24 " Y=" #25
  G0 X[#24] Y[#25]
ENDSUB
```

### Aufruf

**GOSUB:**
```gcode
#24 = 10
#25 = 20
GOSUB meine_routine
```

**M-Code Override:**
```gcode
SUB m100
  MSG "M100 aufgerufen: S=" #19
  M54 P1
ENDSUB

; Im G-Code:
M100 S500               ; #19 = 500
```

### Parameter-Mapping A-Z → #1-#26

| A=#1 | B=#2 | C=#3 | D=#4 | E=#5 | F=#6 |
| G=#7 | H=#8 | I=#9 | J=#10 | K=#11 | L=#12 |
| M=#13 | N=#14 | O=#15 | P=#16 | Q=#17 | R=#18 |
| S=#19 | T=#20 | U=#21 | V=#22 | W=#23 | X=#24 | Y=#25 | Z=#26 |

**Nicht angegebene Parameter:** Wert = -1e10

---

## 12. KONTROLLSTRUKTUREN

### IF / ELSE / ENDIF

```gcode
IF [#1 > 10]
  MSG "Größer 10"
ELSE
  MSG "Kleiner gleich 10"
ENDIF
```

### WHILE / ENDWHILE

```gcode
#100 = 0
WHILE [#100 < 10]
  G0 X[#100 * 10]
  #100 = [#100 + 1]
ENDWHILE
```

### Verschachtelt

```gcode
IF [#1 > 0]
  IF [#2 > 0]
    MSG "Beide positiv"
  ELSE
    MSG "Nur #1 positiv"
  ENDIF
ENDIF
```

---

## 13. HÄUFIGE SYNTAX-FEHLER

### 1. Ausdruck ohne Klammern

```gcode
G0 X10+5        ; FALSCH - wird als X10 interpretiert
G0 X[10+5]      ; RICHTIG - X=15
```

### 2. Modalgruppen-Konflikt

```gcode
G0 G28 X10      ; FEHLER - beide nutzen Achswörter
G28 X10         ; RICHTIG
```

### 3. G38.2 ohne Vorschub

```gcode
G38.2 Z-10      ; FEHLER wenn F nicht gesetzt
F100
G38.2 Z-10      ; RICHTIG
```

### 4. Parameter-Timing

```gcode
#1 = 10
G0 X#1          ; Verwendet ALTEN Wert!

; RICHTIG:
#1 = 10
; Neue Zeile!
G0 X#1
```

### 5. G92 Akkumulation

```gcode
G92 X0          ; Offset = -5 (wenn X=5)
G92 X0          ; Offset = -5 (akkumuliert!)

; RICHTIG:
G92.1           ; Reset
G92 X0
```

### 6. G53 nicht modal

```gcode
G53
G0 X100         ; FEHLER - G53 gilt nur für eine Zeile!

G53 G0 X100     ; RICHTIG
```

### 7. Simulation vergessen

```gcode
G38.2 Z-10      ; Führt im Render bis Endpunkt!

; RICHTIG:
IF [[#5380 == 0] AND [#5397 == 0]]
  G38.2 Z-10
ENDIF
```

### 8. M56 Timeout ohne Prüfung

```gcode
M56 P3 L2 Q30
G0 X100         ; Bewegt auch bei Timeout!

; RICHTIG:
M56 P3 L2 Q30
IF [#5399 == -1]
  ERRMSG "Timeout!"
ENDIF
```

---

## 14. BEST PRACTICES

### Programm-Initialisierung

```gcode
; === SICHERE INITIALISIERUNG ===
G21             ; Millimeter
G90             ; Absolut
G94             ; mm/min
G17             ; XY-Ebene
G40             ; Radiuskorrektur aus
G49             ; Längenversatz aus
G54             ; Koordinatensystem 1
G64 P0.1        ; Vorausschau mit Toleranz
M9              ; Kühlmittel aus
M5              ; Spindel aus
```

### Sichere Werkzeugmessung

```gcode
SUB werkzeugmessung
  ; Nur im normalen Betrieb messen
  IF [[#5380 == 0] AND [#5397 == 0]]
    G90 G53 G0 Z0               ; Sichere Höhe
    G53 G0 X[#4507] Y[#4508]    ; Taster-Position
    G53 G38.2 Z[#4506] F100     ; Messen

    IF [#5067 == 1]
      ; Werkzeuglänge berechnen und speichern
      #5401 = [#5051 - #4506]   ; Tool 1 Offset
      MSG "Tool 1 Länge: " #5401
    ELSE
      ERRMSG "Taster nicht ausgelöst!"
    ENDIF

    G53 G0 Z0                   ; Zurück
  ENDIF
ENDSUB
```

### Fehlerbehandlung

```gcode
; Nach Probing immer prüfen:
IF [#5067 == 0]
  ERRMSG "Probing fehlgeschlagen!"
ENDIF

; Nach I/O mit Timeout:
M56 P3 L1 Q30
IF [#5399 == -1]
  ERRMSG "Sensor-Timeout!"
ENDIF

; Grenzwerte prüfen:
IF [#5001 > 500]
  ERRMSG "X-Position außerhalb Bereich!"
ENDIF
```

### Variablen-Management

```gcode
; "Lokale Variablen" im Bereich #100-#4000
#100 = 10               ; start_x
#101 = 20               ; start_y
#102 = 5                ; step_size
#103 = 0                ; counter

WHILE [#103 < 10]
  G0 X[#100 + [#103 * #102]] Y#101
  #103 = [#103 + 1]
ENDWHILE
```

---

## 15. QUICK REFERENCE

### Kritische Regeln (TOP 10)

1. **Ausdrücke IMMER in []**: `[#1 + 5]`
2. **G38.2**: Braucht F und modal G90/G91
3. **Nur EIN G-Code pro Modalgruppe pro Zeile**
4. **G53 ist NICHT modal** - jede Zeile neu
5. **R bei Festzyklen MUSS > Z sein**
6. **Fräserradiuskorrektur braucht Eintrittsbewegung**
7. **Parameter wirken NACH Zeilen-Auswertung**
8. **G92 akkumuliert** - G92.1 zum Reset
9. **#5380 / #5397 prüfen bei G38.2** (Simulation!)
10. **M56 Timeout: #5399 == -1 prüfen**

### Wichtigste Variablen

```
#5001-5006      Aktuelle Position X-C
#5008           Werkzeugnummer
#5051-5066      Sondenposition Maschine/Arbeit
#5067           Sonde ausgelöst (0/1)
#5220           Koordinatensystem (1-9)
#5380           Simulation (0/1)
#5397           Render (0/1)
#5399           I/O-Rückgabe
#5401-5499      Tool Z-Offset (Länge)
#5501-5599      Tool Durchmesser
```

### Wichtigste G-Codes

```
G0/G1           Eilgang / Vorschub
G2/G3           Bogen CW/CCW
G17/18/19       Ebene XY/XZ/YZ
G20/21          Zoll/mm
G38.2           Probing
G40-42          Radiuskorrektur
G43/49          Längenversatz
G53             Maschinenkoordinaten (nicht modal!)
G54-59.3        Koordinatensysteme 1-9
G90/91          Absolut/Inkrementell
G92             Offset setzen
```

### Wichtigste M-Codes

```
M3/M4/M5        Spindel CW/CCW/Stop
M6              Werkzeugwechsel
M7/M8/M9        Kühlmittel Nebel/Flut/Aus
M30             Programmende
M54/M55         AUX setzen/löschen
M56/M57         AUX lesen Ein-/Ausgang
```

---

## 16. SOROTEC-SPEZIFISCHE KONFIGURATION

### Wichtige Konfigurationsvariablen

```
#4400           Sensor-Typ (0=Öffner, 1=Schließer)
#4506           Sicherheitshöhe Z (Maschinenkoordinaten)
#4507           Werkzeugsensor Position X (Maschinenkoordinaten)
#4508           Werkzeugsensor Position Y (Maschinenkoordinaten)
#4544           3D-Taster-Typ
#4546           Tastradius (KRITISCH - präzise messen!)
```

### Konfiguration durchführen

```gcode
; NUR im MDI-Modus ausführen!
gosub config
```

---

**Ende der Zusammenfassung**

Diese Referenz basiert auf der umfassenden Analyse des offiziellen Eding CNC Handbuchs und deckt alle kritischen Syntaxregeln für die Entwicklung und Korrektur von CNC-Makros für Eding CNC 5.3 ab.
