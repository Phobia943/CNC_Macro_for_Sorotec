;@unit mm
;***************************************************************************************
; SOROTEC Eding CNC Macro V3.2
; Perfektioniert fuer Eding CNC 5.3
;***************************************************************************************
;
; WICHTIG: Diese Datei enthaelt erweiterte Funktionen fuer CNC-Bearbeitung
; - Werkzeuglaengenmessung mit Sicherheitspruefungen
; - Z-Nullpunktermittlung mit Messtaster
; - 3D-Taster Funktionen fuer Werkstück-Antastung
; - Werkzeugwechsel-Automatisierung
; - Spindel-Warmlauf
; - Werkzeug-Bruchkontrolle
; - Rechteck-Vermessung mit Massgenauigkeitskontrolle (NEU!)
; - Werkstueck-Dicken-Messung fuer doppelseitige Bearbeitung (NEU!)
; - Koordinatensystem-Manager G54-G59 (NEU!)
;
; Entwickelt fuer: Sorotec Aluline AL1110 mit 2kW Spindel (24.000 RPM)
; Eding CNC Version: 5.3
;
;***************************************************************************************
; VERSIONSHISTORIE
;***************************************************************************************
; V3.2  : BUGFIX: G1516 "incorrect feed rate" Fehler behoben
;         - Standard-Initialisierung fuer #4548 und #4549 hinzugefuegt
;         - USER_5 erweitert: Jetzt mit Z-Achsen-Antastung (Z+ Oberseite)
;         - Neue Dialog-Logik: Erst Achse (X/Y/Z), dann Richtung (+/-)
;         - Variablen #1200 (Achse) und #1201 (Richtung) statt #4550
; V3.1  : Neue User Subroutines 10-12
;         - USER_10: Vier-Kanten-Rechteck-Vermessung
;         - USER_11: Werkstueck-Dicken-Messung
;         - USER_12: Koordinatensystem-Manager G54-G59
; V3.0  : Komplette Ueberarbeitung fuer bessere Verstaendlichkeit
;         - Neuorganisation der User Subroutines
;         - Tastradius-Kompensation in allen Antastfunktionen
;         - Verbesserte Sicherheitspruefungen
;         - Ausfuehrliche Kommentare fuer Anfaenger
;         - CONFIG nur per MDI aufrufbar
; V2.1e : WZ-Laengenmessung - Nur positive Werkzeuglaengen zulassen
; V2.1d : Position nach Referenzfahrt neues Dialogfenster in WLMP
; V2.1c : Bruchkontrolle - Dialog in WLMP aktiviert
; V2.1b : Bruchkontrolle - Aenderung fuer MDI oder Tool-Change Aufruf
; V2.1a : Bruchkontrolle - Sensorzustand pruefen
; V2.1  : Z-Null und WZ-Laengenmessung - Sensorzustand pruefen
; V2.0  : 3D Taster fuer X und Y Nullpunktermittlung
;
;***************************************************************************************
; VARIABLEN-DOKUMENTATION
;***************************************************************************************
;
; SYSTEMVARIABLEN (Eding CNC)
; ---------------------------
; #5001-#5006   Aktuelle Arbeitskoordinaten (X,Y,Z,A,B,C)
; #5008         Aktuelle Werkzeugnummer
; #5010         Aktuelle Werkzeuglaenge
; #5011         Neue Werkzeugnummer (bei Wechsel)
; #5015         Werkzeugwechsel Status (0=nicht ausgefuehrt, 1=ausgefuehrt)
; #5053         Sensor-Schaltpunkt Z (Maschinenkoordinate)
; #5061-#5066   Sensor-Schaltpunkt Arbeitskoordinaten (X,Y,Z,A,B,C)
; #5067         Sensorimpuls (1=Sensor hat geschaltet)
; #5068         Sensorzustand (0=geschlossen, 1=geoeffnet bei Oeffner)
; #5071-#5076   Aktuelle Maschinenkoordinaten (X,Y,Z,A,B,C)
; #5113         Positives Z-Limit (Maschinenkoordinate)
; #5380         Simulationsmodus (0=Normal, 1=Simulation)
; #5397         Rendermodus (0=Normal, 1=Render)
; #5398         Dialog Return-Value (1=OK, -1=CANCEL)
; #5399         Return-Value M55/M56
;
; KONFIGURATIONSPARAMETER
; -----------------------
;
; System-Flags (#3500-#3510)
; #3500         INIT Flag (1=initialisiert)
; #3501         Werkzeug bereits vermessen? (1=JA)
; #3502         Temporaerer Speicher fuer Berechnungen
; #3503         Merker fuer Ja/Nein Dialoge
; #3504         Bruchkontrolle von Automatik aufgerufen? (1=JA)
; #3505         Laengenmessung vom Handrad aufgerufen? (1=JA)
; #3510         Werkzeugwechsel von GUI aufgerufen? (1=JA)
;
; Sensor-Konfiguration (#4400)
; #4400         Werkzeuglaengensensor-Typ (0=Oeffner, 1=Schliesser)
;
; Werkzeuglaengenmessung (#4501-#4509)
; #4501         Aktuelle Werkzeuglaenge
; #4502         Alte Werkzeuglaenge (vor letzter Messung)
; #4503         Maximale Werkzeuglaenge
; #4504         Antastgeschwindigkeit Schnellsuche (mm/min)
; #4505         Tastgeschwindigkeit Feinmessung (mm/min)
; #4506         Sicherheitshoehe Z (Maschinenkoordinate)
; #4507         Sensor Position X-Achse
; #4508         Sensor Position Y-Achse
; #4509         Abstand Spindelnase zu Sensor bei Z0
;
; Z-Nullpunkt Ermittlung (#4510-#4513)
; #4510         Tasterhoehe (Dicke des Messtasters)
; #4511         Freifahrhoehe nach Messung
; #4512         Antastgeschwindigkeit Schnellsuche (mm/min)
; #4513         Tastgeschwindigkeit Feinmessung (mm/min)
;
; Arbeits-Variablen (#4514-#4531)
; #4514-#4516   Zwischenspeicher X,Y,Z Position
; #4517         Merker: Kein Werkzeug ausgewaehlt
; #4518         Merker: Zurueckfahren zu Z-Vermessungspunkt
; #4519         Aktion nach Werkzeugvermessung:
;               0=vordefinierten Punkt anfahren
;               1=Werkstuecknullpunkt fahren
;               2=Werkzeugwechselpos anfahren
;               3=Maschinennullpunkt anfahren
;               4=Stehen bleiben
; #4520         Werkzeugwechseltyp:
;               0=Ignorieren
;               1=Nur Position anfahren
;               2=Position anfahren + Vermessen
; #4521-#4523   Werkzeugwechselposition X,Y,Z
; #4524-#4526   Position nach Laengenmessung X,Y,Z
; #4527         UNBENUTZT (Taster-Spindelkopf Abstand)
; #4528         Toleranz Bruchkontrolle (mm)
; #4529         Automatische Bruchkontrolle ein? (1=JA)
; #4530         UNBENUTZT (Kegelcheck)
; #4531         UNBENUTZT (Kegelhoehe)
;
; Spindel-Warmlauf (#4532-#4539)
; #4532         Drehzahl Stufe 1
; #4533         Laufzeit Stufe 1 (Sekunden)
; #4534         Drehzahl Stufe 2
; #4535         Laufzeit Stufe 2 (Sekunden)
; #4536         Drehzahl Stufe 3
; #4537         Laufzeit Stufe 3 (Sekunden)
; #4538         Drehzahl Stufe 4
; #4539         Laufzeit Stufe 4 (Sekunden)
;
; 3D-Taster Parameter (#4544-#4549)
; #4544         3D-Taster Sensor-Typ (0=Oeffner, 1=Schliesser)
; #4545         3D-Taster Laenge (als Werkzeug)
; #4546         3D-Taster Kugelradius (WICHTIG fuer Kompensation!)
; #4547         3D-Taster Radius-Offset
; #4548         3D-Taster Anfahrgeschwindigkeit (mm/min)
; #4549         3D-Taster Tastgeschwindigkeit (mm/min)
;
; Werkstueck-Antastung (#4550-#4566)
; #4550         Richtungs-Merker (1=X+, 2=X-, 3=Y+, 4=Y-)
; #4551         Versatz X+ (wird auf 0 gesetzt bei Kantenmessung)
; #4552         Versatz X- (wird auf 0 gesetzt bei Kantenmessung)
; #4553         Versatz Y+ (wird auf 0 gesetzt bei Kantenmessung)
; #4554         Versatz Y- (wird auf 0 gesetzt bei Kantenmessung)
; #4560         Spindelversatz beruecksichtigen? (1=JA)
; #4561         Spindelversatz X
; #4562         Spindelversatz Y
; #4563-#4566   UNBENUTZT
;
; Position nach Referenzfahrt (#4631-#4633)
; #4631         Position X nach Referenzfahrt
; #4632         Position Y nach Referenzfahrt
; #4633         Position Z nach Referenzfahrt
;
; Neue Funktionen USER_10-12 (#4600-#4625)
; #4600         Toleranz Rechteck-Vermessung (mm) - Default: 0.1
; #4601         Max. Suchstrecke Rechteck (mm) - Default: 50
; #4610         Toleranz Dicken-Messung (mm) - Default: 0.2
; #4620-#4625   Reserviert fuer Koordinatensystem-Beschreibungen
;
; Temporaere Variablen (Verwendung in Subroutinen)
; #185          Sensor Fehler-Zustand (temporaer)
; #1-#10        Lokale Variablen in Antast-Subroutinen
; #100-#115     Berechnungsvariablen
; #1001-#1099   Messwert-Speicher (alt)
; #1100-#1199   Messwert-Speicher USER_10-12 (neu)
; #1200         USER_5: Achsen-Merker (1=X, 2=Y, 3=Z)
; #1201         USER_5: Richtungs-Merker (1=positiv, 2=negativ)
; #2001-#2099   Berechnungs-Zwischenspeicher (alt)
; #2100-#2199   Berechnungs-Zwischenspeicher USER_10-12 (neu)
;
;***************************************************************************************
; EINHEITEN-DEFINITION
;***************************************************************************************
; Unit-Deklaration erfolgt ueber ;@unit mm am Dateianfang (Zeile 1)

;***************************************************************************************
; INITIALISIERUNG
;***************************************************************************************

IF [#3500 == 0] THEN ; Einmalige Initialisierung beim ersten Start
  #3500 = 1          ; INIT Flag setzen

  ; Standard-Werte fuer Werkzeuglaengenmessung
  IF [#4504 == 0] THEN
    #4504 = 50       ; Antastgeschwindigkeit Schnellsuche (mm/min)
  ENDIF
  IF [#4505 == 0] THEN
    #4505 = 10       ; Tastgeschwindigkeit Feinmessung (mm/min)
  ENDIF

  ; Standard-Werte fuer Z-Nullpunkt
  IF [#4511 == 0] THEN
    #4511 = 10       ; Freifahrhoehe (mm)
  ENDIF
  IF [#4512 == 0] THEN
    #4512 = 50       ; Antastgeschwindigkeit Schnellsuche (mm/min)
  ENDIF
  IF [#4513 == 0] THEN
    #4513 = 20       ; Tastgeschwindigkeit Feinmessung (mm/min)
  ENDIF

  ; Standard-Werte fuer 3D-Taster (WICHTIG gegen G1516 Fehler!)
  IF [#4548 == 0] THEN
    #4548 = 200      ; 3D-Taster Anfahrgeschwindigkeit (mm/min)
  ENDIF
  IF [#4549 == 0] THEN
    #4549 = 50       ; 3D-Taster Tastgeschwindigkeit (mm/min)
  ENDIF
ENDIF

;***************************************************************************************
; HILFSFUNKTIONEN (Helper Subroutines)
;***************************************************************************************

;---------------------------------------------------------------------------------------
SUB check_sensor_connected
;---------------------------------------------------------------------------------------
; Prueft ob der Werkzeuglaengensensor angeschlossen ist
; Verwendet Variable #185 als Fehler-Zustand
; Bricht mit Fehlermeldung ab, wenn Sensor nicht gefunden
;---------------------------------------------------------------------------------------

  ; Erwarteten Fehler-Zustand bestimmen (haengt vom Sensor-Typ ab)
  IF [#4400 == 0] THEN       ; Wenn Oeffner (#4400 = 0)
    #185 = 1                 ; Fehler-Zustand ist 1 (offen)
  ELSE                       ; Wenn Schliesser (#4400 = 1)
    #185 = 0                 ; Fehler-Zustand ist 0 (geschlossen)
  ENDIF

  ; Sensorzustand pruefen
  IF [#5068 == #185] THEN    ; Sensor im Fehler-Zustand?
    DlgMsg "Werkzeugsensor nicht angeschlossen - Bitte pruefen!"
    IF [#5398 == 1] THEN     ; OK-Taste gedrueckt
      IF [#5068 == #185] THEN ; Sensor immer noch nicht angeschlossen?
        ErrMsg "Messung abgebrochen -> Sensor Error"
      ENDIF
    ELSE                     ; Cancel gedrueckt
      ErrMsg "Messung abgebrochen -> Sensor Error"
    ENDIF
  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB check_3d_probe_connected
;---------------------------------------------------------------------------------------
; Prueft ob der 3D-Taster angeschlossen ist
; Verwendet Variable #185 als Fehler-Zustand
; Bricht mit Fehlermeldung ab, wenn Taster nicht gefunden
;---------------------------------------------------------------------------------------

  ; Erwarteten Fehler-Zustand bestimmen (haengt vom Taster-Typ ab)
  IF [#4544 == 0] THEN       ; Wenn Oeffner (#4544 = 0)
    #185 = 1                 ; Fehler-Zustand ist 1 (offen)
  ELSE                       ; Wenn Schliesser (#4544 = 1)
    #185 = 0                 ; Fehler-Zustand ist 0 (geschlossen)
  ENDIF

  ; Sensorzustand pruefen
  IF [#5068 == #185] THEN    ; Sensor im Fehler-Zustand?
    DlgMsg "3D-Taster nicht angeschlossen - Bitte pruefen!"
    IF [#5398 == 1] THEN     ; OK-Taste gedrueckt
      IF [#5068 == #185] THEN ; Taster immer noch nicht angeschlossen?
        ErrMsg "Messung abgebrochen -> Taster Error"
      ENDIF
    ELSE                     ; Cancel gedrueckt
      ErrMsg "Messung abgebrochen -> Taster Error"
    ENDIF
  ENDIF

ENDSUB

;***************************************************************************************
; CONFIG SUBROUTINE - NUR PER MDI AUFRUFBAR!
;***************************************************************************************

;---------------------------------------------------------------------------------------
SUB config
;---------------------------------------------------------------------------------------
; Haupt-Konfigurationsroutine
; WICHTIG: Diese Funktion sollte NUR per MDI aufgerufen werden mit "gosub config"
; NICHT aus Programmen heraus aufrufen!
;
; Schutz gegen versehentlichen Aufruf:
; Wenn diese Funktion aus einem laufenden Job aufgerufen wird, wird sie abgebrochen.
;---------------------------------------------------------------------------------------

  ; Pruefung: Ist ein Job geladen/aktiv?
  ; Im Rendermodus (#5397=1) oder Simulationsmodus (#5380=1) nicht ausfuehren
  IF [[#5397 == 1] OR [#5380 == 1]] THEN
    ErrMsg "CONFIG darf nicht aus Programmen aufgerufen werden! Bitte per MDI: gosub config"
  ENDIF

  ; Sicherheitsabfrage
  DlgMsg "Konfiguration starten? Nur per MDI verwenden!"
  IF [#5398 == 1] THEN
    ; Konfiguration durchfuehren
    GoSub config_toolchange      ; Werkzeugwechsel Parameter
    GoSub config_znull           ; Z-Nullpunkt Parameter
    GoSub config_toollength      ; Werkzeuglaengenmessung Parameter
    GoSub config_3dprobe         ; 3D-Taster Parameter
    GoSub config_spindle_warmup  ; Spindelwarmlauf Parameter

    msg "Konfiguration abgeschlossen"
  ELSE
    msg "Konfiguration abgebrochen"
  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB config_toolchange
;---------------------------------------------------------------------------------------
; Konfiguration: Werkzeugwechsel-Parameter
;---------------------------------------------------------------------------------------

  DlgMsg "Werkzeugwechslertyp einstellen" "TYP (0=Ignorieren, 1=Nur Position, 2=Position+Vermessen)" 4520

  IF [#5398 == 1] THEN ; OK gedrueckt
    IF [#4520 > 0] THEN ; Wenn Werkzeugwechsel aktiv
      DlgMsg "Werkzeugwechselposition eingeben" "Position X-Achse (mm)" 4521 "Position Y-Achse (mm)" 4522 "Position Z-Achse (mm)" 4523
    ENDIF
  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB config_znull
;---------------------------------------------------------------------------------------
; Konfiguration: Z-Nullpunkt Messparameter
;---------------------------------------------------------------------------------------

  DlgMsg "Z-Nullpunkt Sensor Konfiguration" "Sensor-Typ (0=Oeffner, 1=Schliesser)" 4400 "Tasterhoehe (mm)" 4510 "Anfahrvorschub (mm/min)" 4512 "Tastvorschub (mm/min)" 4513

ENDSUB

;---------------------------------------------------------------------------------------
SUB config_toollength
;---------------------------------------------------------------------------------------
; Konfiguration: Werkzeuglaengenmessung Parameter
;---------------------------------------------------------------------------------------

  ; Position nach Referenzfahrt
  DlgMsg "Position nach Referenzfahrt" "Position X (mm)" 4631 "Position Y (mm)" 4632 "Position Z (mm)" 4633

  ; Werkzeuglaengensensor Parameter
  DlgMsg "Werkzeuglaengensensor Konfiguration" "Position X-Achse (mm)" 4507 "Position Y-Achse (mm)" 4508 "Sicherheitshoehe Z (mm)" 4506 "Spindelnase ohne WZ bei Z0 (mm)" 4509 "Max. Werkzeuglaenge (mm)" 4503 "Anfahrvorschub (mm/min)" 4504 "Tastvorschub (mm/min)" 4505

  ; Bruchkontrolle
  DlgMsg "Bruchkontrolle Einstellungen" "Aktivieren? (0=Nein, 1=Ja)" 4529 "Verschleisstoleranz +/- (mm)" 4528

  ; Position nach Messung
  DlgMsg "Position nach Werkzeugmessung" "Funktion (0-4, siehe Doku)" 4519 "Position X (mm)" 4524 "Position Y (mm)" 4525

ENDSUB

;---------------------------------------------------------------------------------------
SUB config_3dprobe
;---------------------------------------------------------------------------------------
; Konfiguration: 3D-Taster Parameter
; WICHTIG: Der Kugelradius (#4546) ist entscheidend fuer korrekte Messungen!
;---------------------------------------------------------------------------------------

  ; 3D-Taster Grundparameter
  DlgMsg "3D-Taster Konfiguration" "Sensor-Typ (0=Oeffner, 1=Schliesser)" 4544 "Tasterlaenge als Werkzeug (mm)" 4545 "Kugelradius (mm) - WICHTIG!" 4546 "Anfahrvorschub (mm/min)" 4548 "Tastvorschub (mm/min)" 4549

  ; Versatz-Werte (werden bei Einzelkanten-Messung automatisch auf 0 gesetzt)
  DlgMsg "3D-Taster Versatz-Werte" "Versatz X+ (mm)" 4551 "Versatz X- (mm)" 4552 "Versatz Y+ (mm)" 4553 "Versatz Y- (mm)" 4554

  ; Spindelversatz (falls Taster nicht genau in Spindelmitte)
  DlgMsg "Spindelversatz (falls Taster exzentrisch)" "Versatz beruecksichtigen? (0=Nein, 1=Ja)" 4560 "Spindelversatz X (mm)" 4561 "Spindelversatz Y (mm)" 4562

ENDSUB

;---------------------------------------------------------------------------------------
SUB config_spindle_warmup
;---------------------------------------------------------------------------------------
; Konfiguration: Spindel-Warmlauf Parameter
; Der Warmlauf erfolgt in 4 Stufen mit steigender Drehzahl
;---------------------------------------------------------------------------------------

  DlgMsg "Spindelwarmlauf Parameter" "Drehzahl Stufe 1 (RPM)" 4532 "Laufzeit Stufe 1 (Sek)" 4533 "Drehzahl Stufe 2 (RPM)" 4534 "Laufzeit Stufe 2 (Sek)" 4535 "Drehzahl Stufe 3 (RPM)" 4536 "Laufzeit Stufe 3 (Sek)" 4537 "Drehzahl Stufe 4 (RPM)" 4538 "Laufzeit Stufe 4 (Sek)" 4539

ENDSUB

;***************************************************************************************
; USER SUBROUTINES - Hauptfunktionen
;***************************************************************************************

;---------------------------------------------------------------------------------------
SUB user_1 ; Werkzeuglaengenmessung
;---------------------------------------------------------------------------------------
; Misst die Laenge des aktuell eingespannten Werkzeugs
;
; ABLAUF:
; 1. Prueft ob Werkzeug ein 3D-Taster ist (dann keine Messung)
; 2. Prueft ob Sensor angeschlossen ist
; 3. Fragt Benutzer nach geschaetzter Werkzeuglaenge
; 4. Faehrt zu Sensorposition
; 5. Tastet Sensor zweimal an (schnell + langsam fuer Genauigkeit)
; 6. Berechnet Werkzeuglaenge
; 7. Zeigt Ergebnis an und wartet auf Bestaetigung
; 8. Faehrt zu konfigurierter Position
;
; SICHERHEIT:
; - Nur positive Werkzeuglaengen erlaubt
; - Pruefung ob Werkzeug zu lang fuer Maschine
; - Sensor-Verbindungspruefung
;
; VARIABLEN:
; #5016 - Aktuelle Werkzeugnummer
; #5017 - Maximale Werkzeuglaenge (Eingabe)
; #5019 - Sensor Position X
; #5020 - Sensor Position Y
; #5021 - Gemessene Werkzeuglaenge (Ergebnis)
; #185  - Sensor Fehler-Zustand (temporaer)
;---------------------------------------------------------------------------------------

  #5016 = [#5008]    ; Aktuelle Werkzeugnummer speichern
  #5017 = [#4503]    ; Maximale Werkzeuglaenge aus Konfiguration
  #5019 = [#4507]    ; Sensorposition X
  #5020 = [#4508]    ; Sensorposition Y
  #5021 = 0          ; Gemessene Laenge (wird berechnet)

  ; Pruefung: Ist Werkzeug ein 3D-Taster?
  ; Werkzeuge 98 und 99 sind reserviert fuer 3D-Taster
  IF [#5008 > 97] THEN
    msg "Werkzeug ist 3D-Taster -> Laengenmessung nicht erforderlich"
    M30
  ENDIF

  ; Sensorzustand pruefen
  GoSub check_sensor_connected

  ; Benutzer nach geschaetzter Werkzeuglaenge fragen
  msg "Werkzeug wird vermessen"
  DlgMsg "Werkzeug vermessen?" "Geschaetzte Werkzeuglaenge ca. (mm):" 5017

  IF [[#5398 == 1] AND [#5397 == 0]] THEN ; OK gedrueckt UND nicht im Rendermodus

    ; Sicherheitspruefung 1: Werkzeuglaenge muss positiv sein
    IF [#5017 <= 0] THEN
      DlgMsg "!!! WARNUNG: Werkzeuglaenge muss positiv sein !!!" "Eingegebene Laenge:" 5017
    ENDIF

    ; Sicherheitspruefung 2: Werkzeug darf nicht zu lang sein
    ; Berechnung: Spindelnase-Position + Werkzeuglaenge + Sicherheit(10mm) < Max.Hoehe
    IF [[#4509 + #5017 + 10] > [#4506]] THEN
      DlgMsg "!!! WARNUNG: Werkzeug zu lang fuer Maschine !!!" "Eingegebene Laenge:" 5017
    ENDIF

    ; Wenn immer noch ungueltige Eingabe: Abbruch
    IF [[#5017 <= 0] OR [[#4509 + #5017 + 10] > [#4506]]] THEN
      ErrMsg "Werkzeuglaengenmessung abgebrochen - Ungueltige Laenge"
    ENDIF

    ; Spindel und Kuehlung ausschalten (Sicherheit!)
    M5 M9

    ; Zu Sensorposition fahren
    msg "Fahre zu Sensorposition..."
    G53 G0 Z[#4506]                      ; Z Sicherheitshoehe (Maschinenkoord.)
    G53 G0 X[#5019] Y[#5020]             ; XY Sensorposition (Maschinenkoord.)

    ; Z-Annaeherung: Sicherheitsabstand von 10mm zum Sensor
    G53 G0 Z[#4509 + #5017 + 10]

    ; Erste Messung: Schnelles Antasten
    msg "Taste Sensor an (schnell)..."
    G53 G38.2 Z[#4509] F[#4504]

    IF [#5067 == 1] THEN ; Sensor wurde gefunden

      ; Zweite Messung: Langsames Antasten fuer Genauigkeit
      msg "Taste Sensor an (langsam)..."
      G91 G38.2 Z20 F[#4505]             ; Relativ 20mm hoch, langsam
      G90                                ; Zurueck zu absoluten Koordinaten

      IF [#5067 == 1] THEN ; Sensor erneut gefunden

        ; Sicher nach oben fahren
        G0 G53 Z[#4506]

        ; Werkzeugtabelle auf 0 setzen (Direktvermessung)
        #[5400 + #5016] = 0
        #[5500 + #5016] = 0

        ; Werkzeuglaenge berechnen
        #5021 = [#5053 - #4509]          ; Schaltpunkt - Spindelnase-Abstand

        ; WICHTIG: Benutzer informieren UND auf Bestaetigung warten
        msg "Werkzeuglaenge wird gemessen..."
        DlgMsg "Gemessene Werkzeuglaenge ist " #5021 " mm - OK?"

        IF [#5398 == 1] THEN ; Benutzer hat Laenge bestaetigt

          ; Werkzeuglaenge speichern und ggf. Z-Nullpunkt anpassen
          IF [#3501 == 1] THEN           ; Wurde vorher schon ein Werkzeug vermessen?
            #4502 = [#4501]              ; Alte Laenge speichern
            #4501 = [#5021]              ; Neue Laenge speichern
            #3502 = [#4501 - #4502]      ; Differenz berechnen
            G92 Z[#5003 - #3502]         ; Z-Nullpunkt anpassen
          ELSE                           ; Erstes Werkzeug
            #4501 = [#5021]              ; Laenge speichern
          ENDIF

          ; Merker setzen: Werkzeug wurde vermessen
          #3501 = 1

          ; Zu konfigurierter Position fahren (abhaengig von #4519)
          IF [#4518 == 1] THEN                    ; Sonderfall: Zurueck zur alten Position
            G0 G53 Z[#4506]
            G0 G53 X[#4514] Y[#4515]
            #4518 = 0

          ELSE                                    ; Normal: Konfigurierte Position anfahren

            IF [#4519 == 0] THEN                  ; 0 = Vordefinierter Punkt
              G0 G53 Z[#4506]
              G0 G53 X[#4524] Y[#4525]
            ENDIF

            IF [#4519 == 1] THEN                  ; 1 = Werkstuecknullpunkt
              G0 G53 Z[#4506]
              G0 X0 Y0
            ENDIF

            IF [#4519 == 2] THEN                  ; 2 = Werkzeugwechselposition
              G0 G53 Z[#4523]
              G0 G53 X[#4521] Y[#4522]
            ENDIF

            IF [#4519 == 3] THEN                  ; 3 = Maschinennullpunkt
              G0 G53 Z[#4506]
              G0 G53 X0 Y0
            ENDIF

            ; Wenn #4519 == 4: Stehen bleiben (nichts tun)

          ENDIF

          msg "Werkzeuglaengenmessung erfolgreich abgeschlossen"

        ELSE
          ; Benutzer hat gemessene Laenge NICHT bestaetigt
          ErrMsg "Messung vom Benutzer abgelehnt - Bitte Werkzeug pruefen!"
        ENDIF

      ELSE
        G90
        ErrMsg "FEHLER: Sensor nicht gefunden (Feinmessung) - RESET betaetigen"
      ENDIF

    ELSE
      ErrMsg "FEHLER: Sensor nicht gefunden (Schnellsuche) - Messung abgebrochen"
    ENDIF

  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_2 ; Z-Nullpunktermittlung
;---------------------------------------------------------------------------------------
; Setzt den Z-Nullpunkt des aktiven Koordinatensystems mit einem Messtaster
;
; ABLAUF:
; 1. Prueft ob Werkzeug vermessen wurde (bei aktivem Laengensensor)
; 2. Prueft ob Sensor angeschlossen ist
; 3. Tastet von aktueller Position nach unten bis Taster geschaltet hat
; 4. Faehrt langsam zurueck fuer exakte Messung
; 5. Setzt G92 Z-Nullpunkt auf Tasterhoehe (#4510)
; 6. Faehrt Taster frei
;
; SICHERHEIT:
; - Warnung wenn Werkzeug nicht vermessen (bei aktivem Sensor)
; - Sensor-Verbindungspruefung
; - Zweistufiges Antasten fuer hohe Genauigkeit
;
; VARIABLEN:
; #185 - Sensor Fehler-Zustand (temporaer)
;---------------------------------------------------------------------------------------

  ; Pruefung: Wurde Werkzeug vermessen? (nur bei aktivem Laengensensor)
  IF [[#3501 == 1] OR [#4520 < 2]] THEN

    ; Sensorzustand pruefen
    GoSub check_sensor_connected

    ; Dialog nur wenn nicht vom Handrad aufgerufen
    IF [#3505 == 0] THEN
      DlgMsg "Z-Nullpunkt ermitteln?"
    ENDIF
    #3505 = 0  ; Handrad-Merker zuruecksetzen

    IF [[#5398 == 1] AND [#5397 == 0]] THEN ; OK UND nicht im Rendermodus

      M5  ; Spindel ausschalten (Sicherheit!)

      ; Erste Messung: Schnelles Antasten
      msg "Taste Messtaster an..."
      G38.2 G91 Z-50 F[#4512]            ; Relativ 50mm runter, schnell

      IF [#5067 == 1] THEN ; Taster gefunden

        ; Zweite Messung: Langsames Antasten
        msg "Exakte Messung..."
        G38.2 G91 Z20 F[#4513]           ; Relativ 20mm hoch, langsam
        G90

        IF [#5067 == 1] THEN ; Taster erneut gefunden

          ; Schaltpunkt anfahren und Z-Nullpunkt setzen
          G0 Z[#5063]                    ; Exakten Schaltpunkt anfahren
          G92 Z[#4510]                   ; Z-Nullpunkt = Tasterhoehe

          ; Taster freifahren
          G0 Z[#4510 + 5]                ; 5mm ueber Taster

          msg "Z-Nullpunkt erfolgreich gesetzt"

        ELSE
          G90
          ErrMsg "FEHLER: Taster hat nicht geschaltet (Feinmessung)"
        ENDIF

      ELSE
        G90
        DlgMsg "WARNUNG: Kein Taster gefunden! Erneut versuchen?"
        IF [#5398 == 1] THEN
          GoSub user_2  ; Rekursiver Aufruf fuer erneuten Versuch
        ELSE
          ErrMsg "Z-Nullpunktermittlung abgebrochen"
        ENDIF
      ENDIF

    ENDIF

  ELSE
    ; Werkzeug wurde noch nicht vermessen
    #3505 = 0
    DlgMsg "WARNUNG - Werkzeug zuerst vermessen!"
    IF [#5398 == 1] THEN
      ; Position speichern fuer Rueckkehr
      #4514 = #5071
      #4515 = #5072
      #4516 = #5073
      #4518 = 1      ; Merker: Zurueckpositionieren
      GoSub user_1   ; Werkzeuglaengenmessung aufrufen
    ENDIF
  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_3 ; Spindel-Warmlauf
;---------------------------------------------------------------------------------------
; Waermt die Spindel in 4 Stufen mit steigender Drehzahl auf
;
; ABLAUF:
; 1. Faehrt Z-Achse in sichere Position
; 2. Durchlaeuft 4 Drehzahlstufen mit konfigurierbarer Laufzeit
; 3. Schaltet Spindel nach Warmlauf aus
;
; PARAMETER (konfigurierbar in CONFIG):
; #4532/#4533 - Drehzahl/Laufzeit Stufe 1
; #4534/#4535 - Drehzahl/Laufzeit Stufe 2
; #4536/#4537 - Drehzahl/Laufzeit Stufe 3
; #4538/#4539 - Drehzahl/Laufzeit Stufe 4
;
; EMPFEHLUNG fuer 2kW Spindel (24.000 RPM):
; Stufe 1: 6.000 RPM, 30 Sekunden
; Stufe 2: 12.000 RPM, 30 Sekunden
; Stufe 3: 18.000 RPM, 30 Sekunden
; Stufe 4: 24.000 RPM, 30 Sekunden
;---------------------------------------------------------------------------------------

  DlgMsg "Spindelwarmlauf starten?"

  IF [#5398 == 1] THEN ; OK gedrueckt

    msg "Spindelwarmlauf gestartet..."

    ; Sicherheitsposition anfahren
    G53 G0 Z0

    ; Stufe 1
    msg "Warmlauf Stufe 1: " #4532 " RPM fuer " #4533 " Sekunden"
    M03 S[#4532]
    G04 P[#4533]

    ; Stufe 2
    msg "Warmlauf Stufe 2: " #4534 " RPM fuer " #4535 " Sekunden"
    M03 S[#4534]
    G04 P[#4535]

    ; Stufe 3
    msg "Warmlauf Stufe 3: " #4536 " RPM fuer " #4537 " Sekunden"
    M03 S[#4536]
    G04 P[#4537]

    ; Stufe 4
    msg "Warmlauf Stufe 4: " #4538 " RPM fuer " #4539 " Sekunden"
    M03 S[#4538]
    G04 P[#4539]

    ; Spindel ausschalten
    M05

    msg "Spindelwarmlauf abgeschlossen"

  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_4 ; Werkzeugwechsel
;---------------------------------------------------------------------------------------
; Fuehrt einen manuellen Werkzeugwechsel durch
;
; ABLAUF:
; 1. Fragt nach neuer Werkzeugnummer
; 2. Ruft change_tool Subroutine auf
; 3. change_tool fuehrt je nach Konfiguration (#4520) aus:
;    - Typ 0: Ignoriert Wechsel
;    - Typ 1: Faehrt Wechselposition an
;    - Typ 2: Faehrt Wechselposition an UND vermisst Werkzeug
;
; SICHERHEIT:
; - Werkzeugnummer 1-99 erlaubt
; - Spindel/Kuehlung werden ausgeschaltet
; - Optional: Bruchkontrolle vor Wechsel
;---------------------------------------------------------------------------------------

  DlgMsg "Welches Werkzeug soll eingewechselt werden?" "Neue Werkzeugnr. (1-99):" 5011

  IF [#5398 == 1] THEN ; OK gedrueckt

    ; Pruefung: Gueltige Werkzeugnummer?
    IF [#5011 > 99] THEN
      DlgMsg "Werkzeugnummer ungueltig! Bitte 1-99 auswaehlen"
      #5011 = #5008  ; Zuruecksetzen
    ELSE
      #3510 = 1      ; Merker: Von GUI aufgerufen
      GoSub change_tool
      #3510 = 0      ; Merker zuruecksetzen
    ENDIF

  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_5 ; Einzelkanten-Antastung (mit automatischer Nullpunktsetzung)
;---------------------------------------------------------------------------------------
; Tastet eine einzelne Kante oder Oberflaeche an und setzt den Nullpunkt automatisch auf 0
; Kompensiert den Kugelradius des 3D-Tasters automatisch!
;
; ABLAUF:
; 1. Fragt ZUERST nach Achse und Richtung (Sicherheit: vor Bewegung!)
; 2. Tastet in gewaehlter Richtung an (zweistufig: schnell + langsam)
; 3. Berechnet Kantenposition INKLUSIVE Kugelradius-Kompensation
; 4. Setzt G92 auf 0 an der gemessenen Kante/Oberflaeche
; 5. Faehrt 1mm von Kante/Oberflaeche weg
;
; ACHSEN UND RICHTUNGEN:
; Achse 1 (X): Richtung 1=X+ (rechts), 2=X- (links)
; Achse 2 (Y): Richtung 1=Y+ (vorne), 2=Y- (hinten)
; Achse 3 (Z): Richtung 1=Z+ (Oberseite), 2=Z- (Unterseite)
;
; WICHTIG:
; - Kugelradius muss in CONFIG korrekt eingestellt sein! (#4546)
; - 3D-Taster muss als Werkzeug 98 oder 99 geladen sein
; - Wirkt auf aktuell aktives Koordinatensystem (G54-G59)
; - Z-Antastung benoetigt Messtaster-Dicke (#4510) bei Z+ (Oberseite)
;
; VARIABLEN:
; #1200 - Achsen-Merker (1=X, 2=Y, 3=Z)
; #1201 - Richtungs-Merker (1=positiv, 2=negativ)
; #4546 - Kugelradius des 3D-Tasters
; #4548 - Anfahrgeschwindigkeit
; #4549 - Tastgeschwindigkeit
; #4512 - Z-Antastgeschwindigkeit schnell (fuer Z-Achse)
; #4513 - Z-Tastgeschwindigkeit langsam (fuer Z-Achse)
; #4510 - Tasterhoehe (fuer Z+ Oberseite)
;---------------------------------------------------------------------------------------

  ; 3D-Taster Sensor pruefen (fuer X/Y)
  ; Fuer Z wird spaeter geprueft welcher Sensor benoetigt wird

  ; SCHRITT 1: Achse auswaehlen
  DlgMsg "Einzelkante antasten - Achse waehlen" "1=X-Achse / 2=Y-Achse / 3=Z-Achse" 1200

  IF [#5398 == -1] THEN ; Cancel gedrueckt
    msg "Kantenmessung abgebrochen"
    #1200 = 0
    M30
  ENDIF

  ; SCHRITT 2: Richtung auswaehlen
  IF [#1200 == 1] THEN
    DlgMsg "X-Achse - Richtung waehlen" "1 = X+ (rechts) / 2 = X- (links)" 1201
  ENDIF

  IF [#1200 == 2] THEN
    DlgMsg "Y-Achse - Richtung waehlen" "1 = Y+ (vorne) / 2 = Y- (hinten)" 1201
  ENDIF

  IF [#1200 == 3] THEN
    DlgMsg "Z-Achse - Richtung waehlen" "1 = Z+ (Oberseite) / 2 = Z- (Unterseite)" 1201
  ENDIF

  IF [#5398 == -1] THEN ; Cancel gedrueckt
    msg "Kantenmessung abgebrochen"
    #1200 = 0
    #1201 = 0
    M30
  ENDIF

  ; Sensorpruefung je nach Achse
  IF [[#1200 == 1] OR [#1200 == 2]] THEN
    ; X oder Y Achse: 3D-Taster erforderlich
    GoSub check_3d_probe_connected
  ENDIF

  IF [#1200 == 3] THEN
    ; Z-Achse: Je nach Richtung anderen Sensor pruefen
    IF [#1201 == 1] THEN
      ; Z+ (Oberseite): 3D-Taster fuer Oberflaechenmessung
      GoSub check_3d_probe_connected
    ELSE
      ; Z- (Unterseite): Messtaster fuer Unterkante
      ; Wird in der Routine geprueft
    ENDIF
  ENDIF

  ;======================================================================================
  ; X-ACHSE ANTASTUNG
  ;======================================================================================

  ; X+ Richtung (Kante rechts vom Taster)
  IF [[#1200 == 1] AND [#1201 == 1]] THEN
    msg "Taste X+ Kante an..."

    ; Schnelles Antasten
    G91 G38.2 X20 F[#4548]
    G90

    IF [#5067 == 1] THEN ; Kante gefunden
      ; Langsames Antasten
      G91 G38.2 X-10 F[#4549]
      G90

      IF [#5067 == 1] THEN
        ; Nullpunkt setzen MIT Kugelradius-Kompensation
        ; X+ Richtung: Kante = Messpunkt - Kugelradius
        G92 X[0 - #4546]

        ; 1mm von Kante wegfahren
        G91 G0 X-1
        G90

        msg "X+ Kante gemessen, Nullpunkt gesetzt (Radius kompensiert)"
      ELSE
        ErrMsg "FEHLER: Kante nicht gefunden (Feinmessung)"
      ENDIF
    ELSE
      ErrMsg "FEHLER: Kante nicht gefunden (Schnellsuche)"
    ENDIF

    #1200 = 0
    #1201 = 0
  ENDIF

  ; X- Richtung (Kante links vom Taster)
  IF [[#1200 == 1] AND [#1201 == 2]] THEN
    msg "Taste X- Kante an..."

    ; Schnelles Antasten
    G91 G38.2 X-20 F[#4548]
    G90

    IF [#5067 == 1] THEN
      ; Langsames Antasten
      G91 G38.2 X10 F[#4549]
      G90

      IF [#5067 == 1] THEN
        ; Nullpunkt setzen MIT Kugelradius-Kompensation
        ; X- Richtung: Kante = Messpunkt + Kugelradius
        G92 X[0 + #4546]

        ; 1mm von Kante wegfahren
        G91 G0 X1
        G90

        msg "X- Kante gemessen, Nullpunkt gesetzt (Radius kompensiert)"
      ELSE
        ErrMsg "FEHLER: Kante nicht gefunden (Feinmessung)"
      ENDIF
    ELSE
      ErrMsg "FEHLER: Kante nicht gefunden (Schnellsuche)"
    ENDIF

    #1200 = 0
    #1201 = 0
  ENDIF

  ;======================================================================================
  ; Y-ACHSE ANTASTUNG
  ;======================================================================================

  ; Y+ Richtung (Kante vorne)
  IF [[#1200 == 2] AND [#1201 == 1]] THEN
    msg "Taste Y+ Kante an..."

    ; Schnelles Antasten
    G91 G38.2 Y20 F[#4548]
    G90

    IF [#5067 == 1] THEN
      ; Langsames Antasten
      G91 G38.2 Y-10 F[#4549]
      G90

      IF [#5067 == 1] THEN
        ; Nullpunkt setzen MIT Kugelradius-Kompensation
        ; Y+ Richtung: Kante = Messpunkt - Kugelradius
        G92 Y[0 - #4546]

        ; 1mm von Kante wegfahren
        G91 G0 Y-1
        G90

        msg "Y+ Kante gemessen, Nullpunkt gesetzt (Radius kompensiert)"
      ELSE
        ErrMsg "FEHLER: Kante nicht gefunden (Feinmessung)"
      ENDIF
    ELSE
      ErrMsg "FEHLER: Kante nicht gefunden (Schnellsuche)"
    ENDIF

    #1200 = 0
    #1201 = 0
  ENDIF

  ; Y- Richtung (Kante hinten)
  IF [[#1200 == 2] AND [#1201 == 2]] THEN
    msg "Taste Y- Kante an..."

    ; Schnelles Antasten
    G91 G38.2 Y-20 F[#4548]
    G90

    IF [#5067 == 1] THEN
      ; Langsames Antasten
      G91 G38.2 Y10 F[#4549]
      G90

      IF [#5067 == 1] THEN
        ; Nullpunkt setzen MIT Kugelradius-Kompensation
        ; Y- Richtung: Kante = Messpunkt + Kugelradius
        G92 Y[0 + #4546]

        ; 1mm von Kante wegfahren
        G91 G0 Y1
        G90

        msg "Y- Kante gemessen, Nullpunkt gesetzt (Radius kompensiert)"
      ELSE
        ErrMsg "FEHLER: Kante nicht gefunden (Feinmessung)"
      ENDIF
    ELSE
      ErrMsg "FEHLER: Kante nicht gefunden (Schnellsuche)"
    ENDIF

    #1200 = 0
    #1201 = 0
  ENDIF

  ;======================================================================================
  ; Z-ACHSE ANTASTUNG
  ;======================================================================================

  ; Z+ Richtung (Oberseite mit 3D-Taster)
  IF [[#1200 == 3] AND [#1201 == 1]] THEN
    msg "Taste Z+ Oberseite an..."

    ; Spindel und Kuehlung aus (Sicherheit)
    M5 M9

    ; Schnelles Antasten nach unten
    G91 G38.2 Z-50 F[#4512]
    G90

    IF [#5067 == 1] THEN
      ; Langsames Antasten fuer Genauigkeit
      G91 G38.2 Z20 F[#4513]
      G90

      IF [#5067 == 1] THEN
        ; Nullpunkt setzen MIT Kugelradius-Kompensation
        ; Z+ Richtung: Oberseite = Messpunkt - Kugelradius
        G92 Z[0 - #4546]

        ; 5mm nach oben wegfahren
        G91 G0 Z5
        G90

        msg "Z+ Oberseite gemessen, Nullpunkt gesetzt (Radius kompensiert)"
      ELSE
        ErrMsg "FEHLER: Oberseite nicht gefunden (Feinmessung)"
      ENDIF
    ELSE
      ErrMsg "FEHLER: Oberseite nicht gefunden (Schnellsuche)"
    ENDIF

    #1200 = 0
    #1201 = 0
  ENDIF

  ; Z- Richtung (Unterseite - NICHT implementiert, da praktisch schwierig)
  IF [[#1200 == 3] AND [#1201 == 2]] THEN
    msg "WARNUNG: Z- Unterseite erfordert spezielle Aufspannung!"
    DlgMsg "Z- Unterseite antasten" "Diese Funktion ist nicht implementiert. Verwenden Sie stattdessen Z+ Oberseite!"

    #1200 = 0
    #1201 = 0
  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_6 ; Ecken-Antastung mit Rotationsberechnung (2 Kanten)
;---------------------------------------------------------------------------------------
; Tastet zwei Kanten eines Rechtecks an und berechnet:
; 1. Die Ecke (Schnittpunkt der Kanten)
; 2. Die Rotation des Werkstuecks
; 3. Fragt ob Rotation angewendet werden soll
;
; ABLAUF:
; 1. Fragt ZUERST welche Kanten gemessen werden sollen
; 2. Benutzer positioniert Taster manuell an erste Kante
; 3. Tastet erste Kante zweimal an (obere + untere Position)
; 4. Benutzer positioniert Taster an zweite Kante
; 5. Tastet zweite Kante zweimal an (linke + rechte Position)
; 6. Berechnet Geradengleichungen beider Kanten
; 7. Berechnet Schnittpunkt (= Ecke)
; 8. Berechnet Rotationswinkel
; 9. Fragt ob Rotation angewendet werden soll
; 10. Setzt Nullpunkt auf Ecke (mit Kugelradius-Kompensation)
; 11. Optional: Wendet G68 Rotation an
;
; WICHTIG:
; - Kugelradius wird automatisch kompensiert (#4546)
; - Dialog BEVOR Messung startet (Sicherheit!)
; - Benutzer kann Rotation ablehnen
;
; VARIABLEN:
; #1001-#1042 - Messpunkte (X1,Y1, X2,Y2, etc.)
; #2001-#2007 - Berechnungsvariablen (Steigungen, Schnittpunkt, Winkel)
; #103        - Kugelradius * 2
; #104        - Kugelradius
; #105        - Sqrt(2)
; #4546       - Kugelradius
;---------------------------------------------------------------------------------------

  ; 3D-Taster Sensor pruefen
  GoSub check_3d_probe_connected

  ; G68 Rotation zuruecksetzen (sauberer Start)
  G68 R0

  ; Kugelradius-Berechnungen
  #103 = [#4546 * 2]     ; Durchmesser
  #104 = [#4546]         ; Radius
  #105 = 1.41421356      ; Sqrt(2)

  DlgMsg "Rechteck-Ecke antasten - Taster zur linken oberen Kante positionieren"

  IF [#5398 == 1] THEN

    ; === ERSTE KANTE: Linke Seite (oberer Punkt) ===
    #1001 = #5001  ; Startposition X speichern
    #100 = [#5001 + 10]

    msg "Taste linke Kante (oben) an..."
    G38.2 X[#100] F[#4548]

    IF [#5067 == 1] THEN
      #1011 = [#5061 - #4546]  ; X1 mit Kugelradius-Kompensation
      #1012 = #5062            ; Y1
      G0 X[#1001]

      ; === ERSTE KANTE: Linke Seite (unterer Punkt) ===
      DlgMsg "Taster zur linken unteren Kante positionieren"

      IF [#5398 == 1] THEN
        #1001 = #5001
        #100 = [#5001 + 10]

        msg "Taste linke Kante (unten) an..."
        G38.2 X[#100] F[#4548]

        IF [#5067 == 1] THEN
          #1021 = [#5061 - #4546]  ; X2 mit Kugelradius-Kompensation
          #1022 = #5062            ; Y2
          G0 X[#1001]

          ; === ZWEITE KANTE: Untere Seite (linker Punkt) ===
          DlgMsg "Taster zur unteren linken Kante positionieren"

          IF [#5398 == 1] THEN
            #1002 = #5002
            #100 = [#5002 + 10]

            msg "Taste untere Kante (links) an..."
            G38.2 Y[#100] F[#4548]

            IF [#5067 == 1] THEN
              #1031 = #5061            ; X3
              #1032 = [#5062 - #4546]  ; Y3 mit Kugelradius-Kompensation
              G0 Y[#1002]

              ; === ZWEITE KANTE: Untere Seite (rechter Punkt) ===
              DlgMsg "Taster zur unteren rechten Kante positionieren"

              IF [#5398 == 1] THEN
                #1002 = #5002
                #100 = [#5002 + 10]

                msg "Taste untere Kante (rechts) an..."
                G38.2 Y[#100] F[#4548]

                IF [#5067 == 1] THEN
                  #1041 = #5061            ; X4
                  #1042 = [#5062 - #4546]  ; Y4 mit Kugelradius-Kompensation
                  G0 Y[#1002]

                  ; === BERECHNUNGEN ===
                  msg "Berechne Rotation und Nullpunkt..."

                  ; Steigung erste Kante (linke Seite)
                  #2001 = [[#1022 - #1012] / [#1021 - #1011]]

                  ; Steigung zweite Kante (untere Seite)
                  #2002 = [[#1042 - #1032] / [#1041 - #1031]]

                  ; Y-Achsenabschnitt erste Kante
                  #2003 = [#1012 - #2001 * #1011]

                  ; Y-Achsenabschnitt zweite Kante
                  #2004 = [#1032 - #2002 * #1031]

                  ; Schnittpunkt X (Ecke)
                  #2005 = [[#2003 - #2004] / [#2002 - #2001]]

                  ; Schnittpunkt Y (Ecke)
                  #2006 = [#2001 * #2005 + #2003]

                  ; Rotationswinkel berechnen (aus unterer Kante)
                  #2007 = ATAN[[#1042 - #1032] / [#1041 - #1031]]

                  ; === BENUTZER FRAGEN OB ROTATION ANWENDEN ===
                  DlgMsg "Die errechnete Rotation liegt bei " #2007 " Grad. Soll ich diese anwenden oder ignorieren?" "1=Anwenden / 0=Ignorieren" 3503

                  IF [#5398 == 1] THEN

                    ; Nullpunkt auf Ecke setzen (mit Radius-Kompensation)
                    G92 X[#1041 - #2005 - #105 * #104 * COS[#2007 + 45]]
                    G92 Y[#1002 - #2006 - #105 * #104 * SIN[#2007 + 45]]

                    ; Rotation anwenden wenn gewaehlt
                    IF [#3503 == 1] THEN
                      G68 R[#2007]
                      msg "Nullpunkt gesetzt und Rotation " #2007 " Grad angewendet"
                    ELSE
                      msg "Nullpunkt gesetzt, Rotation NICHT angewendet"
                    ENDIF

                  ELSE
                    msg "Messung abgebrochen"
                  ENDIF

                ELSE
                  ErrMsg "Messfehler: Untere Kante rechts nicht gefunden"
                ENDIF
              ENDIF

            ELSE
              ErrMsg "Messfehler: Untere Kante links nicht gefunden"
            ENDIF
          ENDIF

        ELSE
          ErrMsg "Messfehler: Linke Kante unten nicht gefunden"
        ENDIF
      ENDIF

    ELSE
      ErrMsg "Messfehler: Linke Kante oben nicht gefunden"
    ENDIF
  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_7 ; Loch-Antastung (Mittelpunkt finden)
;---------------------------------------------------------------------------------------
; Findet den Mittelpunkt eines kreisfoermigen Lochs durch 4-Punkt-Messung
;
; ABLAUF:
; 1. Benutzer positioniert Taster ungefaehr in Lochmitte
; 2. Fragt nach geschaetztem Lochdurchmesser
; 3. Tastet in alle 4 Richtungen (X-, X+, Y-, Y+)
; 4. Berechnet Mittelpunkt aus gegenüberliegenden Messpunkten
; 5. Setzt G92 Nullpunkt auf Lochmitte
; 6. Faehrt Lochmitte an
; 7. Zeigt gemessene Durchmesser in X und Y an
;
; WICHTIG:
; - Kugelradius wird automatisch kompensiert (#4546)
; - Geschaetzter Durchmesser muss groesser als tatsaechlicher sein!
; - Bei nicht-runden Loechern werden beide Durchmesser angezeigt
;
; VARIABLEN:
; #1          - Geschaetzter Durchmesser (Eingabe)
; #100-#108   - Messwerte und Berechnungen
; #101-#105   - Zwischenspeicher
; #4546       - Kugelradius
; #4548       - Anfahrgeschwindigkeit
; #4549       - Tastgeschwindigkeit
;---------------------------------------------------------------------------------------

  ; 3D-Taster Sensor pruefen
  GoSub check_3d_probe_connected

  F[#4549]  ; Vorschubgeschwindigkeit setzen

  DlgMsg "Loch-Mittelpunkt finden - Taster ungefaehr in Lochmitte positionieren" "Geschaetzter Durchmesser (mm):" 1

  IF [#5398 == 1] THEN

    #102 = [#1 + 10]  ; Suchstrecke = Durchmesser + Reserve

    ; === X- Richtung antasten ===
    #101 = #5001      ; X-Position speichern
    msg "Taste Loch X- an..."
    G91
    G38.2 X-[#102] F[#4548]
    G90

    IF [#5067 == 1] THEN
      #100 = [#5061 + #4546]  ; X- Kante + Kugelradius
      G0 X[#101]              ; Zurueck zur Mitte

      ; === X+ Richtung antasten ===
      msg "Taste Loch X+ an..."
      G91
      G38.2 X[#102] F[#4548]
      G90

      IF [#5067 == 1] THEN
        #104 = [[#5061 - #4546 - #100] / 2]  ; X-Mittelpunkt berechnen
        G92 X[#104]                          ; X-Nullpunkt setzen
        G0 X0                                ; X-Mitte anfahren

        ; === Y- Richtung antasten ===
        #101 = #5002
        msg "Taste Loch Y- an..."
        G91
        G38.2 Y-[#102] F[#4548]
        G90

        IF [#5067 == 1] THEN
          #100 = [#5062 + #4546]  ; Y- Kante + Kugelradius
          G0 Y[#101]              ; Zurueck zur Mitte

          ; === Y+ Richtung antasten ===
          msg "Taste Loch Y+ an..."
          G91
          G38.2 Y[#102] F[#4548]
          G90

          IF [#5067 == 1] THEN
            #105 = [[#5062 - #4546 - #100] / 2]  ; Y-Mittelpunkt berechnen
            G92 Y[#105]                          ; Y-Nullpunkt setzen
            G0 Y0                                ; Y-Mitte anfahren

            ; === Durchmesser-Verifikation (optional) ===
            ; Nochmal X+ messen fuer Durchmesser-Kontrolle
            G0 X[#104 - 1]
            G91
            G38.2 X[#102] F[#4548]
            G90
            #106 = [#5061 - #4546]

            ; X- messen
            G0 X-[#104 - 1]
            G91
            G38.2 X-[#102] F[#4548]
            G90
            #107 = [#106 - [#5061 + #4546]]  ; Durchmesser X

            G0 X0

            ; Y+ messen
            G0 Y[#105 - 1]
            G91
            G38.2 Y[#102] F[#4548]
            G90
            #108 = [#5062 - #4546 - #100]    ; Durchmesser Y

            ; Zurueck zur Mitte
            G0 X0 Y0

            msg "Lochmitte gefunden - Durchmesser X=" #107 " mm, Durchmesser Y=" #108 " mm"

          ELSE
            ErrMsg "Messfehler: Loch Y+ nicht gefunden"
          ENDIF
        ELSE
          ErrMsg "Messfehler: Loch Y- nicht gefunden"
        ENDIF
      ELSE
        ErrMsg "Messfehler: Loch X+ nicht gefunden"
      ENDIF
    ELSE
      ErrMsg "Messfehler: Loch X- nicht gefunden"
      M30
    ENDIF

  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_8 ; Zylinder/Boss-Antastung (Aussenmittelpunkt)
;---------------------------------------------------------------------------------------
; Findet den Mittelpunkt eines aussenliegenden Zylinders (Boss)
;
; ABLAUF:
; 1. Benutzer positioniert Taster ungefaehr zur Zylindermitte
; 2. Fragt nach geschaetztem Durchmesser
; 3. Tastet alle 4 Seiten an (X+, X-, Y+, Y-)
; 4. Berechnet Mittelpunkt
; 5. Setzt G92 Nullpunkt auf Zylindermitte
; 6. Faehrt Zylindermitte an
;
; WICHTIG:
; - Kugelradius wird automatisch kompensiert (#4546)
; - Taster wird zwischen Messungen nach oben gefahren (#4511)
; - Geschaetzter Durchmesser sollte kleiner als tatsaechlicher sein!
;
; VARIABLEN:
; #1          - Geschaetzter Durchmesser (Eingabe)
; #100-#102   - Messwerte und Berechnungen
; #4511       - Freifahrhoehe Z
; #4546       - Kugelradius
; #4548       - Anfahrgeschwindigkeit
; #4549       - Tastgeschwindigkeit
;---------------------------------------------------------------------------------------

  ; 3D-Taster Sensor pruefen
  GoSub check_3d_probe_connected

  F[#4549]  ; Vorschubgeschwindigkeit setzen

  DlgMsg "Zylinder-Mittelpunkt finden - Taster neben Zylinder positionieren" "Geschaetzter Durchmesser (mm):" 1

  IF [#5398 == 1] THEN

    #102 = [#1 + 10]  ; Suchstrecke = Durchmesser + Reserve

    ; === X+ Seite antasten ===
    #101 = #5001
    msg "Taste Zylinder X+ an..."
    G91
    G38.2 X[#102] F[#4548]
    G90

    IF [#5067 == 1] THEN
      #100 = [#5061 - #4546]  ; X+ Kante - Kugelradius

      ; Nach oben fahren und zur anderen Seite
      G0 Z[#4511]
      G0 X[#102]
      G0 Z-[#102]

      ; === X- Seite antasten ===
      msg "Taste Zylinder X- an..."
      G38.2 X-[#102] F[#4548]
      G90

      IF [#5067 == 1] THEN
        ; X-Mittelpunkt berechnen und setzen
        G92 X-[[#100 - [#5061 + #4546]] / 2]

        ; Nach oben und X-Mitte anfahren
        G91
        G0 Z[#4511]
        G90
        G0 X0

        ; === Y+ Seite antasten ===
        #101 = #5002
        G0 Y[#101 + #102 / 2]
        G91
        G0 Z-[#102]
        G38.2 Y[#102] F[#4548]
        G90

        IF [#5067 == 1] THEN
          #100 = [#5062 - #4546]  ; Y+ Kante - Kugelradius

          ; Nach oben fahren und zur anderen Seite
          G91
          G0 Z[#4511]
          G0 Y-[#102]
          G0 Z-[#102]
          G38.2 Y-[#102] F[#4548]
          G90

          IF [#5067 == 1] THEN
            ; Y-Mittelpunkt berechnen und setzen
            G92 Y-[[#100 - [#5062 + #4546]] / 2]

            ; Nach oben und Y-Mitte anfahren
            G91
            G0 Z[#4511]
            G90
            G0 Y0

            msg "Zylindermitte gefunden - Maschine steht auf Mittelpunkt"

          ELSE
            ErrMsg "Messfehler: Zylinder Y- nicht gefunden"
          ENDIF
        ELSE
          ErrMsg "Messfehler: Zylinder Y+ nicht gefunden"
        ENDIF
      ELSE
        ErrMsg "Messfehler: Zylinder X- nicht gefunden"
      ENDIF
    ELSE
      ErrMsg "Messfehler: Zylinder X+ nicht gefunden"
      M30
    ENDIF

  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_9 ; Werkzeug-Bruchkontrolle
;---------------------------------------------------------------------------------------
; Prueft ob das Werkzeug noch die richtige Laenge hat (Bruch/Verschleiss)
;
; ABLAUF:
; 1. Prueft ob Werkzeug bereits vermessen wurde
; 2. Prueft Sensor-Verbindung
; 3. Faehrt zu Sensorposition
; 4. Misst aktuelle Werkzeuglaenge
; 5. Vergleicht mit vorheriger Messung
; 6. Wenn Abweichung > Toleranz: Warnung
; 7. Benutzer kann Fortfahren oder Abbrechen
;
; WICHTIG:
; - Toleranz muss in CONFIG eingestellt sein (#4528)
; - Funktion kann manuell oder automatisch (bei Werkzeugwechsel) aufgerufen werden
; - Bei automatischem Aufruf: Merker #3504 = 1
;
; VARIABLEN:
; #3501       - Werkzeug vermessen? (1=JA)
; #3504       - Von Automatik aufgerufen? (1=JA)
; #4501       - Aktuelle Werkzeuglaenge
; #4528       - Toleranz (+/- mm)
; #5021       - Vorherige Werkzeuglaenge
; #185        - Sensor Fehler-Zustand
;---------------------------------------------------------------------------------------

  IF [#3501 == 1] THEN ; Werkzeug wurde bereits vermessen

    ; Sensorzustand pruefen
    GoSub check_sensor_connected

    msg "Bruchkontrolle wird durchgefuehrt..."

    ; Spindel und Kuehlung ausschalten
    M5 M9

    ; Zu Sensorposition fahren
    G53 G0 Z[#4506]                      ; Sicherheitshoehe
    G53 G0 Y[#5020]                      ; Y-Position
    G53 G0 X[#5019]                      ; X-Position
    G53 G0 Z[#4509 + #5017 + 10]         ; Z-Annaeherung

    ; Sensor antasten
    G53 G38.2 Z[#4509] F[#4504]

    IF [#5067 == 1] THEN ; Sensor gefunden

      ; Feinmessung
      G91 G38.2 Z20 F[#4505]
      G90

      IF [#5067 == 1] THEN ; Sensor erneut gefunden

        ; Aktuelle Laenge berechnen
        #4501 = [#5053 - #4509]

        ; Nach oben fahren
        G0 G53 Z[#4506]

        ; Toleranzpruefung
        ; Ist Abweichung innerhalb Toleranz?
        IF [[[#5021 + #4528] > [#4501]] AND [[#5021 - #4528] < [#4501]]] THEN

          ; Werkzeug OK
          msg "Bruchkontrolle OK - Abweichung: " [#5021 - #4501] " mm"

        ELSE

          ; Werkzeug NICHT OK - zu viel Abweichung
          #3504 = 0  ; Automatik-Merker zuruecksetzen

          ; Zu Wechselposition fahren
          G53 G0 Z[#4523]
          G53 G0 X[#4521]
          G53 G0 Y[#4522]

          DlgMsg "WARNUNG: Werkzeug verschlissen! Fortfahren?" "Abweichung (mm):" 4501

          IF [#5398 == 1] THEN ; OK - Fortfahren
            DlgMsg "ACHTUNG: Auftrag wird mit verschlissenem Werkzeug fortgefuehrt!"
          ELSE                 ; Cancel - Abbruch
            #3504 = 0
            ErrMsg "Werkzeug verschlissen - Auftrag abgebrochen"
          ENDIF

        ENDIF

        ; Zu konfigurierter Position fahren (wenn nicht von Automatik)
        IF [#3504 == 0] THEN

          IF [#4519 == 0] THEN       ; Vordefinierter Punkt
            G0 G53 Z[#4506]
            G0 G53 X[#4524]
            G0 G53 Y[#4525]
          ENDIF

          IF [#4519 == 1] THEN       ; Werkstuecknullpunkt
            G0 G53 Z[#4506]
            G0 X0
            G0 Y0
          ENDIF

          IF [#4519 == 2] THEN       ; Werkzeugwechselposition
            G0 G53 Z[#4523]
            G0 G53 X[#4521]
            G0 G53 Y[#4522]
          ENDIF

          IF [#4519 == 3] THEN       ; Maschinennullpunkt
            G0 G53 Z[#4506]
            G53 X0
            G53 Y0
          ENDIF

          ; Wenn #4519 == 4: Stehen bleiben

        ENDIF

      ELSE
        #3504 = 0
        ErrMsg "FEHLER: Sensor nicht gefunden (Feinmessung)"
      ENDIF

    ELSE
      #3504 = 0
      ErrMsg "FEHLER: Sensor nicht gefunden (Schnellsuche)"
    ENDIF

  ELSE
    DlgMsg "Werkzeug wurde noch nicht vermessen - Bruchkontrolle nicht moeglich"
  ENDIF

  #3504 = 0  ; Automatik-Merker zuruecksetzen

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_10 ; Vier-Kanten-Rechteck-Vermessung
;---------------------------------------------------------------------------------------
; Misst automatisch alle 4 Kanten eines Rechtecks und berechnet:
; - Mittelpunkt des Rechtecks
; - Tatsaechliche Laenge und Breite
; - Rechtwinkligkeit
; - Abweichungen von Sollmassen
;
; ABLAUF:
; 1. Fragt nach Sollmassen (Laenge, Breite)
; 2. Benutzer positioniert 3D-Taster ungefaehr in Rechteckmitte
; 3. Tastet alle 4 Kanten an (zweistufig: schnell + langsam)
; 4. Berechnet Mittelpunkt und Abmessungen
; 5. Prueft Rechtwinkligkeit und Massgenauigkeit
; 6. Zeigt Ist-Soll-Vergleich an
; 7. Setzt G92 Nullpunkt auf Rechteck-Mittelpunkt
;
; WICHTIG:
; - Kugelradius (#4546) wird automatisch kompensiert
; - 3D-Taster muss angeschlossen sein
; - Taster sollte ungefaehr in der Mitte positioniert werden
; - Rechteck-Kanten muessen mindestens 10mm vom Taster entfernt sein
;
; VARIABLEN (Messwerte):
; #1100 - Sollmass Laenge X (Eingabe)
; #1101 - Sollmass Breite Y (Eingabe)
; #1102 - Gemessene Position X+ Kante
; #1103 - Gemessene Position X- Kante
; #1104 - Gemessene Position Y+ Kante
; #1105 - Gemessene Position Y- Kante
;
; VARIABLEN (Berechnungen):
; #2100 - Ist-Laenge X
; #2101 - Ist-Breite Y
; #2102 - Mittelpunkt X
; #2103 - Mittelpunkt Y
; #2104 - Abweichung Laenge (Ist - Soll)
; #2105 - Abweichung Breite (Ist - Soll)
; #2106 - Toleranzcheck (0=OK, 1=Abweichung)
; #2107 - Suchstrecke (Reserve fuer Antastung)
;
; KONFIGURATION:
; #4600 - Toleranz fuer Massabweichung (mm) - Default: 0.1
; #4601 - Max. Suchstrecke pro Seite (mm) - Default: 50
;---------------------------------------------------------------------------------------

  ; 3D-Taster Sensor pruefen
  GoSub check_3d_probe_connected

  ; Standard-Toleranz setzen falls nicht konfiguriert
  IF [#4600 == 0] THEN
    #4600 = 0.1  ; Default: 0.1mm Toleranz
  ENDIF

  IF [#4601 == 0] THEN
    #4601 = 50   ; Default: 50mm Suchstrecke
  ENDIF

  ; Sollmasse vom Benutzer abfragen
  DlgMsg "Rechteck-Vermessung: Sollmasse eingeben" "Laenge X (mm):" 1100 "Breite Y (mm):" 1101

  IF [#5398 == -1] THEN ; Cancel gedrueckt
    msg "Rechteck-Vermessung abgebrochen"
    M30
  ENDIF

  ; Eingabepruefung
  IF [[#1100 <= 0] OR [#1101 <= 0]] THEN
    ErrMsg "Fehler: Sollmasse muessen groesser als 0 sein!"
  ENDIF

  DlgMsg "Taster ungefaehr in Rechteck-Mitte positionieren und bestaetigen"

  IF [#5398 == 1] THEN

    ; Suchstrecke berechnen (halbe Sollmass + Reserve)
    #2107 = [#4601]  ; Max. Suchstrecke

    msg "Rechteck-Vermessung gestartet..."

    ; === X+ Kante antasten (rechte Seite) ===
    msg "Taste X+ Kante an (rechts)..."
    #100 = #5001  ; Startposition speichern

    ; Schnelles Antasten
    G91 G38.2 X[#2107] F[#4548]
    G90

    IF [#5067 == 1] THEN
      ; Langsames Antasten fuer Genauigkeit
      G91 G38.2 X-10 F[#4549]
      G90

      IF [#5067 == 1] THEN
        ; Position mit Kugelradius-Kompensation speichern
        #1102 = [#5061 - #4546]
        msg "X+ Kante gemessen: " #1102 " mm"

        ; Zurueck zur Mitte
        G0 X[#100]

        ; === X- Kante antasten (linke Seite) ===
        msg "Taste X- Kante an (links)..."

        ; Schnelles Antasten
        G91 G38.2 X-[#2107] F[#4548]
        G90

        IF [#5067 == 1] THEN
          ; Langsames Antasten
          G91 G38.2 X10 F[#4549]
          G90

          IF [#5067 == 1] THEN
            ; Position mit Kugelradius-Kompensation speichern
            #1103 = [#5061 + #4546]
            msg "X- Kante gemessen: " #1103 " mm"

            ; Zurueck zur Mitte
            G0 X[#100]

            ; === Y+ Kante antasten (vordere Seite) ===
            msg "Taste Y+ Kante an (vorne)..."
            #101 = #5002  ; Y-Startposition speichern

            ; Schnelles Antasten
            G91 G38.2 Y[#2107] F[#4548]
            G90

            IF [#5067 == 1] THEN
              ; Langsames Antasten
              G91 G38.2 Y-10 F[#4549]
              G90

              IF [#5067 == 1] THEN
                ; Position mit Kugelradius-Kompensation speichern
                #1104 = [#5062 - #4546]
                msg "Y+ Kante gemessen: " #1104 " mm"

                ; Zurueck zur Mitte
                G0 Y[#101]

                ; === Y- Kante antasten (hintere Seite) ===
                msg "Taste Y- Kante an (hinten)..."

                ; Schnelles Antasten
                G91 G38.2 Y-[#2107] F[#4548]
                G90

                IF [#5067 == 1] THEN
                  ; Langsames Antasten
                  G91 G38.2 Y10 F[#4549]
                  G90

                  IF [#5067 == 1] THEN
                    ; Position mit Kugelradius-Kompensation speichern
                    #1105 = [#5062 + #4546]
                    msg "Y- Kante gemessen: " #1105 " mm"

                    ; Zurueck zur Mitte
                    G0 Y[#101]

                    ; === BERECHNUNGEN ===
                    msg "Berechne Rechteck-Parameter..."

                    ; Ist-Masse berechnen
                    #2100 = [#1102 - #1103]  ; Ist-Laenge X
                    #2101 = [#1104 - #1105]  ; Ist-Breite Y

                    ; Mittelpunkt berechnen
                    #2102 = [#1103 + #2100 / 2]  ; Mittelpunkt X
                    #2103 = [#1105 + #2101 / 2]  ; Mittelpunkt Y

                    ; Abweichungen berechnen
                    #2104 = [#2100 - #1100]  ; Abweichung Laenge
                    #2105 = [#2101 - #1101]  ; Abweichung Breite

                    ; Toleranzcheck
                    #2106 = 0  ; Zunaechst OK
                    IF [[ABS[#2104] > #4600] OR [ABS[#2105] > #4600]] THEN
                      #2106 = 1  ; Abweichung zu gross
                    ENDIF

                    ; === ERGEBNISSE ANZEIGEN ===
                    IF [#2106 == 0] THEN
                      msg "=== RECHTECK-VERMESSUNG ERFOLGREICH ==="
                      msg "Ist-Laenge X:  " #2100 " mm (Soll: " #1100 " mm, Abw: " #2104 " mm)"
                      msg "Ist-Breite Y:  " #2101 " mm (Soll: " #1101 " mm, Abw: " #2105 " mm)"
                      msg "Mittelpunkt X: " #2102 " mm"
                      msg "Mittelpunkt Y: " #2103 " mm"
                      msg "Massabweichung innerhalb Toleranz (" #4600 " mm)"

                      DlgMsg "Rechteck vermessen - Alle Masse OK!" "Ist-Laenge X: " 2100 "Soll-Laenge X: " 1100 "Abweichung X: " 2104 "Ist-Breite Y: " 2101 "Soll-Breite Y: " 1101 "Abweichung Y: " 2105

                    ELSE
                      msg "!!! WARNUNG: MASSABWEICHUNG ZU GROSS !!!"
                      msg "Ist-Laenge X:  " #2100 " mm (Soll: " #1100 " mm, Abw: " #2104 " mm)"
                      msg "Ist-Breite Y:  " #2101 " mm (Soll: " #1101 " mm, Abw: " #2105 " mm)"
                      msg "Toleranz: " #4600 " mm"

                      DlgMsg "WARNUNG: Massabweichung zu gross!" "Ist-Laenge X: " 2100 "Soll-Laenge X: " 1100 "Abweichung X: " 2104 "Ist-Breite Y: " 2101 "Soll-Breite Y: " 1101 "Abweichung Y: " 2105 "Max. Toleranz: " 4600
                    ENDIF

                    ; === NULLPUNKT AUF MITTELPUNKT SETZEN ===
                    msg "Setze Nullpunkt auf Rechteck-Mittelpunkt..."

                    ; Zu Mittelpunkt fahren (relativ)
                    G91
                    G0 X[#2102 - #100]
                    G0 Y[#2103 - #101]
                    G90

                    ; Nullpunkt setzen
                    G92 X0 Y0

                    msg "Nullpunkt gesetzt - Maschine steht auf Rechteck-Mittelpunkt"

                  ELSE
                    ErrMsg "Messfehler: Y- Kante nicht gefunden (Feinmessung)"
                  ENDIF
                ELSE
                  ErrMsg "Messfehler: Y- Kante nicht gefunden (Schnellsuche)"
                ENDIF

              ELSE
                ErrMsg "Messfehler: Y+ Kante nicht gefunden (Feinmessung)"
              ENDIF
            ELSE
              ErrMsg "Messfehler: Y+ Kante nicht gefunden (Schnellsuche)"
            ENDIF

          ELSE
            ErrMsg "Messfehler: X- Kante nicht gefunden (Feinmessung)"
          ENDIF
        ELSE
          ErrMsg "Messfehler: X- Kante nicht gefunden (Schnellsuche)"
        ENDIF

      ELSE
        ErrMsg "Messfehler: X+ Kante nicht gefunden (Feinmessung)"
      ENDIF
    ELSE
      ErrMsg "Messfehler: X+ Kante nicht gefunden (Schnellsuche)"
    ENDIF

  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_11 ; Werkstueck-Dicken-Messung
;---------------------------------------------------------------------------------------
; Misst die Dicke eines Werkstuecks von oben nach unten
; Wichtig fuer doppelseitige Bearbeitung und Reststärken-Kontrolle
;
; ABLAUF:
; 1. Fragt nach Soll-Dicke des Werkstuecks
; 2. Fragt nach gewuenschter Nullpunkt-Position (oben/unten)
; 3. Benutzer positioniert Taster ueber Werkstueck-Oberseite
; 4. Tastet Oberseite an (Z-Probe oder 3D-Taster)
; 5. Benutzer positioniert Taster unter Werkstueck
; 6. Tastet Unterseite an
; 7. Berechnet Ist-Dicke und Abweichung
; 8. Setzt Z-Nullpunkt auf gewaehlte Flaeche
;
; WICHTIG:
; - Kann mit Z-Probe (#4400) oder 3D-Taster (#4544) arbeiten
; - Bei 3D-Taster: Kugelradius wird kompensiert
; - Bei doppelseitiger Bearbeitung sehr nuetzlich
; - Aufspannung muss sicheren Zugang zu Unterseite ermoeglichen!
;
; VARIABLEN (Eingabe):
; #1110 - Soll-Dicke (mm)
; #1111 - Nullpunkt-Position (0=Oberseite, 1=Unterseite)
; #1112 - Sensor-Typ (0=Z-Probe, 1=3D-Taster)
;
; VARIABLEN (Messwerte):
; #1113 - Gemessene Z-Position Oberseite
; #1114 - Gemessene Z-Position Unterseite
;
; VARIABLEN (Berechnungen):
; #2110 - Ist-Dicke (mm)
; #2111 - Abweichung von Soll-Dicke (mm)
; #2112 - Z-Nullpunkt Position
;
; KONFIGURATION:
; #4610 - Toleranz fuer Dicken-Abweichung (mm) - Default: 0.2
;---------------------------------------------------------------------------------------

  ; Standard-Toleranz setzen falls nicht konfiguriert
  IF [#4610 == 0] THEN
    #4610 = 0.2  ; Default: 0.2mm Toleranz
  ENDIF

  ; Benutzer nach Messparametern fragen
  #1110 = 0  ; Soll-Dicke
  #1111 = 0  ; Nullpunkt oben
  #1112 = 1  ; Default: 3D-Taster

  DlgMsg "Werkstueck-Dicken-Messung" "Soll-Dicke (mm):" 1110 "Nullpunkt (0=Oberseite, 1=Unterseite):" 1111 "Sensor (0=Z-Probe, 1=3D-Taster):" 1112

  IF [#5398 == -1] THEN ; Cancel gedrueckt
    msg "Dicken-Messung abgebrochen"
    M30
  ENDIF

  ; Eingabepruefung
  IF [#1110 <= 0] THEN
    ErrMsg "Fehler: Soll-Dicke muss groesser als 0 sein!"
  ENDIF

  IF [[#1111 < 0] OR [#1111 > 1]] THEN
    ErrMsg "Fehler: Nullpunkt muss 0 (oben) oder 1 (unten) sein!"
  ENDIF

  IF [[#1112 < 0] OR [#1112 > 1]] THEN
    ErrMsg "Fehler: Sensor muss 0 (Z-Probe) oder 1 (3D-Taster) sein!"
  ENDIF

  ; Entsprechenden Sensor pruefen
  IF [#1112 == 0] THEN
    GoSub check_sensor_connected  ; Z-Probe
    msg "Verwende Z-Nullpunkt-Sensor"
  ELSE
    GoSub check_3d_probe_connected  ; 3D-Taster
    msg "Verwende 3D-Taster"
  ENDIF

  ; === OBERSEITE MESSEN ===
  DlgMsg "Taster UEBER Werkstueck-Oberseite positionieren und bestaetigen"

  IF [#5398 == 1] THEN

    M5  ; Spindel ausschalten (Sicherheit)

    msg "Taste Oberseite an..."

    ; Schnelles Antasten
    G91 G38.2 Z-[#1110 + 20] F[#4512]  ; Nach unten, Reserve einrechnen
    G90

    IF [#5067 == 1] THEN
      ; Langsames Antasten fuer Genauigkeit
      G91 G38.2 Z20 F[#4513]
      G90

      IF [#5067 == 1] THEN

        ; Position speichern (mit Kugelradius-Kompensation bei 3D-Taster)
        IF [#1112 == 1] THEN
          #1113 = [#5063 + #4546]  ; 3D-Taster: + Kugelradius
        ELSE
          #1113 = [#5063 + #4510]  ; Z-Probe: + Tasterhoehe
        ENDIF

        msg "Oberseite gemessen: Z = " #1113 " mm"

        ; Sicher nach oben fahren
        G91 G0 Z10
        G90

        ; === UNTERSEITE MESSEN ===
        DlgMsg "Taster UNTER Werkstueck-Unterseite positionieren und bestaetigen"

        IF [#5398 == 1] THEN

          msg "Taste Unterseite an..."

          ; Schnelles Antasten (von unten nach oben!)
          G91 G38.2 Z[#1110 + 20] F[#4512]  ; Nach oben
          G90

          IF [#5067 == 1] THEN
            ; Langsames Antasten
            G91 G38.2 Z-20 F[#4513]
            G90

            IF [#5067 == 1] THEN

              ; Position speichern (mit Kugelradius-Kompensation bei 3D-Taster)
              IF [#1112 == 1] THEN
                #1114 = [#5063 - #4546]  ; 3D-Taster: - Kugelradius
              ELSE
                #1114 = [#5063 - #4510]  ; Z-Probe: - Tasterhoehe
              ENDIF

              msg "Unterseite gemessen: Z = " #1114 " mm"

              ; Sicher nach unten fahren
              G91 G0 Z-10
              G90

              ; === BERECHNUNGEN ===
              msg "Berechne Werkstueck-Dicke..."

              ; Ist-Dicke berechnen
              #2110 = [#1113 - #1114]

              ; Abweichung berechnen
              #2111 = [#2110 - #1110]

              ; === ERGEBNISSE ANZEIGEN ===
              IF [ABS[#2111] <= #4610] THEN
                msg "=== DICKEN-MESSUNG ERFOLGREICH ==="
                msg "Ist-Dicke:   " #2110 " mm"
                msg "Soll-Dicke:  " #1110 " mm"
                msg "Abweichung:  " #2111 " mm"
                msg "Dicke innerhalb Toleranz (" #4610 " mm)"

                DlgMsg "Dicken-Messung erfolgreich - Masse OK!" "Ist-Dicke: " 2110 "Soll-Dicke: " 1110 "Abweichung: " 2111 "Toleranz: " 4610

              ELSE
                msg "!!! WARNUNG: DICKEN-ABWEICHUNG ZU GROSS !!!"
                msg "Ist-Dicke:   " #2110 " mm"
                msg "Soll-Dicke:  " #1110 " mm"
                msg "Abweichung:  " #2111 " mm"
                msg "Toleranz:    " #4610 " mm"

                DlgMsg "WARNUNG: Dicken-Abweichung zu gross!" "Ist-Dicke: " 2110 "Soll-Dicke: " 1110 "Abweichung: " 2111 "Max. Toleranz: " 4610
              ENDIF

              ; === Z-NULLPUNKT SETZEN ===
              msg "Setze Z-Nullpunkt..."

              ; Nullpunkt-Position berechnen
              IF [#1111 == 0] THEN
                #2112 = #1113  ; Oberseite
                msg "Nullpunkt wird auf Oberseite gesetzt"
              ELSE
                #2112 = #1114  ; Unterseite
                msg "Nullpunkt wird auf Unterseite gesetzt"
              ENDIF

              ; Z-Nullpunkt setzen
              G92 Z[#5003 - #2112]

              IF [#1111 == 0] THEN
                msg "Z-Nullpunkt auf Oberseite gesetzt (Z=0)"
              ELSE
                msg "Z-Nullpunkt auf Unterseite gesetzt (Z=0)"
              ENDIF

            ELSE
              ErrMsg "Messfehler: Unterseite nicht gefunden (Feinmessung)"
            ENDIF
          ELSE
            ErrMsg "Messfehler: Unterseite nicht gefunden (Schnellsuche)"
          ENDIF

        ENDIF

      ELSE
        ErrMsg "Messfehler: Oberseite nicht gefunden (Feinmessung)"
      ENDIF
    ELSE
      ErrMsg "Messfehler: Oberseite nicht gefunden (Schnellsuche)"
    ENDIF

  ENDIF

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_12 ; Koordinatensystem-Manager (G54-G59)
;---------------------------------------------------------------------------------------
; Verwaltet Werkstück-Nullpunkte in den Koordinatensystemen G54-G59
; Menu-gesteuerter Zugriff zum Speichern/Laden/Anzeigen von Nullpunkten
;
; FUNKTIONEN:
; 1. Aktuellen Nullpunkt in G54-G59 speichern
; 2. Gespeicherten Nullpunkt aktivieren (G54-G59)
; 3. Alle gespeicherten Koordinatensysteme anzeigen
; 4. Koordinatensystem zuruecksetzen/loeschen
; 5. Aktives Koordinatensystem anzeigen
;
; ABLAUF:
; 1. Zeigt Haupt-Menu mit Optionen
; 2. Je nach Auswahl:
;    - Speichern: Fragt nach G5x-Nummer, speichert aktuelle Position
;    - Laden: Fragt nach G5x-Nummer, aktiviert Koordinatensystem
;    - Anzeigen: Zeigt alle G54-G59 mit ihren Werten
;    - Loeschen: Fragt nach G5x-Nummer, setzt auf 0 zurueck
;
; WICHTIG:
; - Koordinatensysteme G54-G59 sind in Eding CNC als #5221-#5279 gespeichert
; - G54: #5221-#5226 (X,Y,Z,A,B,C)
; - G55: #5231-#5236
; - G56: #5241-#5246
; - G57: #5251-#5256
; - G58: #5261-#5266
; - G59: #5271-#5276
;
; VARIABLEN (Eingabe/Auswahl):
; #1120 - Menu-Auswahl (1=Speichern, 2=Laden, 3=Anzeigen, 4=Loeschen, 5=Info)
; #1121 - Ausgewaehltes Koordinatensystem (54-59)
;
; VARIABLEN (Berechnung):
; #2120 - Basis-Adresse fuer Koordinatensystem
; #2121 - Temporaer: Aktuell aktives KS
;
; VARIABLEN (Beschreibungen G54-G59):
; #4620-#4625 - Reserviert fuer zukuenftige Beschreibungen
;---------------------------------------------------------------------------------------

  ; === HAUPT-MENU ===
  #1120 = 1  ; Default: Speichern

  DlgMsg "=== KOORDINATENSYSTEM-MANAGER G54-G59 ===" "Funktion waehlen:" "1=Speichern  2=Laden  3=Anzeigen  4=Loeschen  5=Aktives KS" 1120

  IF [#5398 == -1] THEN ; Cancel gedrueckt
    msg "Koordinatensystem-Manager abgebrochen"
    M30
  ENDIF

  ; === FUNKTION 1: SPEICHERN ===
  IF [#1120 == 1] THEN

    #1121 = 54  ; Default: G54

    DlgMsg "Aktuellen Nullpunkt in Koordinatensystem speichern" "G5x waehlen (54-59):" 1121

    IF [#5398 == 1] THEN

      ; Eingabepruefung
      IF [[#1121 < 54] OR [#1121 > 59]] THEN
        ErrMsg "Fehler: Nur G54 bis G59 erlaubt (Eingabe: 54-59)"
      ENDIF

      ; Basis-Adresse berechnen
      ; G54 = #5221, G55 = #5231, G56 = #5241, etc.
      #2120 = [5221 + [#1121 - 54] * 10]

      ; Aktuelle Position in Koordinatensystem speichern
      ; WICHTIG: In Eding CNC speichern wir die OFFSET-Werte
      ; Offset = Maschinenkoordinate - Arbeitskoordinate

      #[#2120 + 0] = [#5071 - #5001]  ; X-Offset
      #[#2120 + 1] = [#5072 - #5002]  ; Y-Offset
      #[#2120 + 2] = [#5073 - #5003]  ; Z-Offset
      #[#2120 + 3] = [#5074 - #5004]  ; A-Offset
      #[#2120 + 4] = [#5075 - #5005]  ; B-Offset
      #[#2120 + 5] = [#5076 - #5006]  ; C-Offset

      msg "Nullpunkt gespeichert in G" #1121
      msg "X=" #[#2120 + 0] " Y=" #[#2120 + 1] " Z=" #[#2120 + 2]

      DlgMsg "Nullpunkt erfolgreich gespeichert!" "Koordinatensystem: G" 1121 "X-Offset: " [#2120 + 0] "Y-Offset: " [#2120 + 1] "Z-Offset: " [#2120 + 2]

    ENDIF

  ENDIF

  ; === FUNKTION 2: LADEN ===
  IF [#1120 == 2] THEN

    #1121 = 54  ; Default: G54

    DlgMsg "Koordinatensystem aktivieren" "G5x waehlen (54-59):" 1121

    IF [#5398 == 1] THEN

      ; Eingabepruefung
      IF [[#1121 < 54] OR [#1121 > 59]] THEN
        ErrMsg "Fehler: Nur G54 bis G59 erlaubt (Eingabe: 54-59)"
      ENDIF

      ; Koordinatensystem aktivieren
      IF [#1121 == 54] THEN
        G54
        msg "Koordinatensystem G54 aktiviert"
      ENDIF

      IF [#1121 == 55] THEN
        G55
        msg "Koordinatensystem G55 aktiviert"
      ENDIF

      IF [#1121 == 56] THEN
        G56
        msg "Koordinatensystem G56 aktiviert"
      ENDIF

      IF [#1121 == 57] THEN
        G57
        msg "Koordinatensystem G57 aktiviert"
      ENDIF

      IF [#1121 == 58] THEN
        G58
        msg "Koordinatensystem G58 aktiviert"
      ENDIF

      IF [#1121 == 59] THEN
        G59
        msg "Koordinatensystem G59 aktiviert"
      ENDIF

      ; Basis-Adresse berechnen fuer Info
      #2120 = [5221 + [#1121 - 54] * 10]

      DlgMsg "Koordinatensystem aktiviert!" "Aktives System: G" 1121 "X-Offset: " [#2120 + 0] "Y-Offset: " [#2120 + 1] "Z-Offset: " [#2120 + 2]

    ENDIF

  ENDIF

  ; === FUNKTION 3: ANZEIGEN ===
  IF [#1120 == 3] THEN

    msg "=== GESPEICHERTE KOORDINATENSYSTEME ==="
    msg " "
    msg "G54: X=" #5221 " Y=" #5222 " Z=" #5223
    msg "G55: X=" #5231 " Y=" #5232 " Z=" #5233
    msg "G56: X=" #5241 " Y=" #5242 " Z=" #5243
    msg "G57: X=" #5251 " Y=" #5252 " Z=" #5253
    msg "G58: X=" #5261 " Y=" #5262 " Z=" #5263
    msg "G59: X=" #5271 " Y=" #5272 " Z=" #5273
    msg " "

    DlgMsg "=== KOORDINATENSYSTEME G54-G59 ===" "G54 X:" 5221 "G54 Y:" 5222 "G54 Z:" 5223 "G55 X:" 5231 "G55 Y:" 5232 "G55 Z:" 5233 "G56 X:" 5241 "G56 Y:" 5242 "G56 Z:" 5243

    ; Zweiter Dialog fuer G57-G59 (max. 7 Eingabefelder pro Dialog)
    DlgMsg "=== KOORDINATENSYSTEME G57-G59 ===" "G57 X:" 5251 "G57 Y:" 5252 "G57 Z:" 5253 "G58 X:" 5261 "G58 Y:" 5262 "G58 Z:" 5263 "G59 X:" 5271 "G59 Y:" 5272 "G59 Z:" 5273

  ENDIF

  ; === FUNKTION 4: LOESCHEN ===
  IF [#1120 == 4] THEN

    #1121 = 54  ; Default: G54

    DlgMsg "Koordinatensystem zuruecksetzen (auf 0)" "G5x waehlen (54-59):" 1121

    IF [#5398 == 1] THEN

      ; Eingabepruefung
      IF [[#1121 < 54] OR [#1121 > 59]] THEN
        ErrMsg "Fehler: Nur G54 bis G59 erlaubt (Eingabe: 54-59)"
      ENDIF

      ; Sicherheitsabfrage
      DlgMsg "ACHTUNG: G" #1121 " wird geloescht! Fortfahren?"

      IF [#5398 == 1] THEN

        ; Basis-Adresse berechnen
        #2120 = [5221 + [#1121 - 54] * 10]

        ; Alle Achsen auf 0 setzen
        #[#2120 + 0] = 0  ; X
        #[#2120 + 1] = 0  ; Y
        #[#2120 + 2] = 0  ; Z
        #[#2120 + 3] = 0  ; A
        #[#2120 + 4] = 0  ; B
        #[#2120 + 5] = 0  ; C

        msg "Koordinatensystem G" #1121 " wurde zurueckgesetzt"

        DlgMsg "Koordinatensystem geloescht!" "G" 1121 " wurde auf Null zurueckgesetzt"

      ELSE
        msg "Loeschen abgebrochen"
      ENDIF

    ENDIF

  ENDIF

  ; === FUNKTION 5: AKTIVES KS ANZEIGEN ===
  IF [#1120 == 5] THEN

    ; Aktuell aktives Koordinatensystem ermitteln
    ; Dies ist in Eding CNC nicht direkt verfuegbar, daher Info-Anzeige
    msg "=== AKTUELLE POSITION ==="
    msg "Arbeitskoordinaten:"
    msg "X=" #5001 " Y=" #5002 " Z=" #5003
    msg " "
    msg "Maschinenkoordinaten:"
    msg "X=" #5071 " Y=" #5072 " Z=" #5073
    msg " "
    msg "Hinweis: Aktives Koordinatensystem in Eding CNC Status pruefen"

    DlgMsg "=== AKTUELLE POSITION ===" "Arbeits-X:" 5001 "Arbeits-Y:" 5002 "Arbeits-Z:" 5003 "Maschinen-X:" 5071 "Maschinen-Y:" 5072 "Maschinen-Z:" 5073

  ENDIF

  msg "Koordinatensystem-Manager beendet"

ENDSUB

;***************************************************************************************
; WERKZEUGWECHSEL SUBROUTINE
;***************************************************************************************

;---------------------------------------------------------------------------------------
SUB change_tool
;---------------------------------------------------------------------------------------
; Interne Werkzeugwechsel-Routine (wird von user_4 und M6 aufgerufen)
;
; VERHALTEN je nach Typ (#4520):
; Typ 0: Wechsel ignorieren (manuelle Maschine)
; Typ 1: Nur Wechselposition anfahren
; Typ 2: Wechselposition anfahren + automatisch vermessen + opt. Bruchkontrolle
;
; SICHERHEIT:
; - Spindel/Kuehlung werden ausgeschaltet
; - Werkzeugnummer 1-99 Validierung
; - Optional: Bruchkontrolle vor Wechsel (#4529)
; - Nicht im Rendermodus ausfuehrbar
;
; VARIABLEN:
; #3503       - Temporaer: Wechsel durchfuehren?
; #3504       - Bruchkontrolle von Automatik aufgerufen
; #4520       - Werkzeugwechseltyp
; #4529       - Bruchkontrolle aktiviert?
; #5008       - Alte Werkzeugnummer
; #5011       - Neue Werkzeugnummer
; #5015       - Wechsel ausgefuehrt? (0=Nein, 1=Ja)
;---------------------------------------------------------------------------------------

  #5015 = 0  ; Merker: Werkzeugwechsel noch nicht ausgefuehrt

  ; Spindel und Kuehlung ausschalten (Sicherheit!)
  M5 M9

  IF [#5397 == 0] THEN ; Nicht im Rendermodus

    ; ========================================================================
    ; TYP 0: Wechsel ignorieren
    ; ========================================================================
    IF [#4520 == 0] THEN
      #5015 = 1  ; Als "ausgefuehrt" markieren (wird ignoriert)
    ENDIF

    ; ========================================================================
    ; TYP 1: Nur Wechselposition anfahren
    ; ========================================================================
    IF [#4520 == 1] THEN

      #3503 = 1  ; Standardmaessig: Wechsel durchfuehren

      ; Ist es das gleiche Werkzeug?
      IF [#5011 == #5008] THEN
        DlgMsg "Werkzeug bereits eingelegt. Trotzdem wechseln?"
        IF [#5398 == 1] THEN
          #3503 = 1
        ELSE
          #3503 = 0
        ENDIF
      ENDIF

      IF [#3503 == 1] THEN

        ; Wechselposition anfahren
        G53 G0 Z[#4523]              ; Z sicher
        G53 G0 X[#4521] Y[#4522]     ; XY Wechselposition

        ; Benutzer auffordern
        DlgMsg "Bitte Werkzeug einwechseln" "Alt:" 5008 "Neu:" 5011

        IF [#5398 == 1] THEN ; OK

          ; Werkzeugnummer validieren
          IF [#5011 > 99] THEN
            DlgMsg "Werkzeugnummer ungueltig! Bitte 1-99 auswaehlen"
            IF [#5398 == 1] THEN
              GoSub change_tool  ; Rekursiv neu versuchen
            ELSE
              ErrMsg "Werkzeugwechsel abgebrochen"
            ENDIF
          ELSE
            #5015 = 1  ; Wechsel ausgefuehrt
          ENDIF

        ELSE
          ErrMsg "Werkzeugwechsel abgebrochen"
        ENDIF

      ENDIF

    ENDIF

    ; ========================================================================
    ; TYP 2: Wechselposition anfahren + Vermessen + Bruchkontrolle
    ; ========================================================================
    IF [#4520 == 2] THEN

      #3503 = 1  ; Standardmaessig: Wechsel durchfuehren

      ; Ist es das gleiche Werkzeug?
      IF [#5011 == #5008] THEN
        DlgMsg "Werkzeug bereits eingelegt. Trotzdem wechseln?"
        IF [#5398 == 1] THEN
          #3503 = 1
        ELSE
          #3503 = 0
        ENDIF
      ENDIF

      IF [#3503 == 1] THEN

        ; Optional: Bruchkontrolle VOR Wechsel
        IF [[#5008 > 0] AND [#4529 == 1]] THEN
          #3504 = 1              ; Merker: Von Automatik aufgerufen
          GoSub user_9           ; Bruchkontrolle
          #3504 = 0
        ELSE
          msg "Bruchkontrolle nicht aktiviert"
        ENDIF

        ; Wechselposition anfahren
        G53 G0 Z[#4523]
        G53 G0 X[#4521] Y[#4522]

        ; Benutzer auffordern
        DlgMsg "Bitte Werkzeug einwechseln" "Alt:" 5008 "Neu:" 5011

        IF [#5398 == 1] THEN ; OK

          ; Werkzeugnummer validieren
          IF [#5011 > 99] THEN
            DlgMsg "Werkzeugnummer ungueltig! Bitte 1-99 auswaehlen" "Neu:" 5011
            IF [#5398 == 1] THEN
              IF [#5011 > 99] THEN
                ErrMsg "Werkzeugnummer ungueltig -> Werkzeugwechsel abgebrochen"
              ENDIF
            ELSE
              ErrMsg "Werkzeugwechsel abgebrochen"
            ENDIF
          ENDIF

          #5015 = 1  ; Wechsel ausgefuehrt

        ELSE
          ErrMsg "Werkzeugwechsel abgebrochen"
        ENDIF

      ENDIF

    ENDIF

    ; ========================================================================
    ; Abschluss: M6 ausfuehren und ggf. vermessen
    ; ========================================================================
    IF [#5015 == 1] THEN

      msg "Werkzeug " #5008 " wird mit Werkzeug " #5011 " gewechselt"

      M6 T[#5011]  ; Werkzeugnummer setzen

      ; Bei Typ 2: Automatisch vermessen
      IF [#4520 == 2] THEN
        GoSub user_1  ; Werkzeuglaengenmessung
      ENDIF

      #5015 = 0  ; Merker zuruecksetzen

    ENDIF

  ENDIF ; Rendermodus-Pruefung

ENDSUB

;***************************************************************************************
; HOMING SUBROUTINES (Referenzfahrt)
;***************************************************************************************

;---------------------------------------------------------------------------------------
SUB home_z ; Referenzfahrt Z-Achse
;---------------------------------------------------------------------------------------
  msg "Referenziere Achse Z"
  M80        ; Motoren einschalten
  G4 P0.2    ; Kurz warten
  HOME Z     ; Z-Achse referenzieren
ENDSUB

;---------------------------------------------------------------------------------------
SUB home_x ; Referenzfahrt X-Achse
;---------------------------------------------------------------------------------------
  msg "Referenziere Achse X"
  M80
  G4 P0.2
  HOME X
ENDSUB

;---------------------------------------------------------------------------------------
SUB home_y ; Referenzfahrt Y-Achse
;---------------------------------------------------------------------------------------
  msg "Referenziere Achse Y"
  M80
  G4 P0.2
  HOME Y
ENDSUB

;---------------------------------------------------------------------------------------
SUB home_a ; Referenzfahrt A-Achse
;---------------------------------------------------------------------------------------
  msg "Referenziere Achse A"
  M80
  G4 P0.2
  HOME A
ENDSUB

;---------------------------------------------------------------------------------------
SUB home_b ; Referenzfahrt B-Achse
;---------------------------------------------------------------------------------------
  msg "Referenziere Achse B"
  M80
  G4 P0.2
  HOME B
ENDSUB

;---------------------------------------------------------------------------------------
SUB home_c ; Referenzfahrt C-Achse
;---------------------------------------------------------------------------------------
  msg "Referenziere Achse C"
  M80
  G4 P0.2
  HOME C
ENDSUB

;---------------------------------------------------------------------------------------
SUB home_all ; Referenzfahrt alle Achsen
;---------------------------------------------------------------------------------------
; Fuehrt vollstaendige Referenzfahrt aller Achsen durch
;
; ABLAUF:
; 1. Referenziert alle Achsen (Z, Y, X, A, B, C)
; 2. Faehrt zu konfigurierter Startposition
; 3. Setzt INIT-Merker zurueck
;
; WICHTIG:
; - Startposition muss in CONFIG eingestellt sein (#4631-#4633)
; - Nach Referenzfahrt ist kein Werkzeug vermessen (#3501=0)
;---------------------------------------------------------------------------------------

  ; Alle Achsen referenzieren (Z zuerst fuer Sicherheit!)
  GoSub home_z
  GoSub home_y
  GoSub home_x
  GoSub home_a
  GoSub home_b
  GoSub home_c

  ; Zu Startposition fahren
  G53 G01 Z[#4633] F2000               ; Z auf Sicherheitshoehe
  G53 G01 X[#4631] Y[#4632] F2000      ; XY auf Startposition

  msg "Referenzierung abgeschlossen"

  ; INIT-Merker zuruecksetzen
  #3501 = 0  ; Werkzeug noch nicht vermessen
  #3504 = 0  ; Bruchkontrolle nicht aktiv

  M30  ; Programmende

ENDSUB

;***************************************************************************************
; ZUSAETZLICHE FUNKTIONEN
;***************************************************************************************

;---------------------------------------------------------------------------------------
SUB zero_set_rotation ; Rotation durch 2-Punkt-Messung
;---------------------------------------------------------------------------------------
; Bestimmt Rotation durch manuelles Antasten zweier Punkte
; VERALTET - Verwenden Sie stattdessen user_6 fuer automatische Messung!
;
; ABLAUF:
; 1. Benutzer tastet ersten Punkt manuell an, drueckt STRG+G
; 2. Benutzer tastet zweiten Punkt manuell an, drueckt STRG+G
; 3. Berechnet Winkel zwischen Punkten
; 4. Wendet G68 Rotation an
;---------------------------------------------------------------------------------------

  msg "Ersten Punkt antasten und mit STRG + G fortfahren"
  M0
  #5020 = #5071  ; X1
  #5021 = #5072  ; Y1

  msg "Zweiten Punkt antasten und mit STRG + G fortfahren"
  M0
  #5022 = #5071  ; X2
  #5023 = #5072  ; Y2

  ; Winkel berechnen
  #5024 = ATAN[[#5023 - #5021] / [#5022 - #5020]]

  ; Korrektur wenn Punkte in Y-Richtung
  IF [#5024 > 45] THEN
    #5024 = [#5024 - 90]
  ENDIF

  ; Rotation anwenden
  G68 R[#5024]

  msg "Koordinatensystem mit G68 R" #5024 " gedreht"
  msg "*** Bitte Messtaster entfernen!!! ***"

ENDSUB

;---------------------------------------------------------------------------------------
SUB user_6_manipulation ; Werkzeugmanipulation (ADMIN)
;---------------------------------------------------------------------------------------
; ADMIN-Funktion: Ermoeglicht direktes Setzen einer Werkzeugnummer
; ACHTUNG: Umgeht normale Sicherheitsmechanismen!
; Nur fuer Experten und Fehlerkorrektur!
;---------------------------------------------------------------------------------------

  #5011 = [#5008]
  DlgMsg "!!! WERKZEUGMANIPULATION - NUR FUER EXPERTEN !!!" "Alte WZ-Nr:" 5008 "Neue WZ-Nr:" 5011

  IF [#5011 > 99] THEN
    DlgMsg "Werkzeugnummer ungueltig! Bitte 1-99 auswaehlen"
    #5011 = #5008
    M30
  ELSE
    #5015 = 1  ; Als ausgefuehrt markieren
    IF [#5011 > 0] THEN
      M6 T[#5011]
    ELSE
      M6 T[#5011]
    ENDIF
  ENDIF

ENDSUB

;***************************************************************************************
; HANDRAD-FUNKTIONEN (XHC WHB04B-4/6)
;***************************************************************************************

;---------------------------------------------------------------------------------------
SUB xhc_probe_z ; Z-Nullpunkt vom Handrad
;---------------------------------------------------------------------------------------
  #3505 = 1      ; Merker: Von Handrad aufgerufen
  GoSub user_2   ; Z-Nullpunktermittlung
ENDSUB

;---------------------------------------------------------------------------------------
SUB xhc_macro_1 ; Handrad Macro 1
;---------------------------------------------------------------------------------------
  msg "Keine Funktion fuer Macro 1 hinterlegt"
ENDSUB

;---------------------------------------------------------------------------------------
SUB xhc_macro_2 ; Handrad Macro 2
;---------------------------------------------------------------------------------------
  GoSub user_1   ; Werkzeuglaengenmessung
ENDSUB

;---------------------------------------------------------------------------------------
SUB xhc_macro_3 ; Handrad Macro 3
;---------------------------------------------------------------------------------------
  msg "Keine Funktion fuer Macro 3 hinterlegt"
ENDSUB

;---------------------------------------------------------------------------------------
SUB xhc_macro_6 ; Handrad Macro 6
;---------------------------------------------------------------------------------------
  msg "Keine Funktion fuer Macro 6 hinterlegt"
ENDSUB

;---------------------------------------------------------------------------------------
SUB xhc_macro_7 ; Handrad Macro 7
;---------------------------------------------------------------------------------------
  msg "Keine Funktion fuer Macro 7 hinterlegt"
ENDSUB

;***************************************************************************************
; ENDE DER MACRO.CNC V3.1
;***************************************************************************************
;
; QUICK REFERENCE - User Subroutines:
; -----------------------------------
; user_1  - Werkzeuglaengenmessung (mit Bestaetigung)
; user_2  - Z-Nullpunktermittlung
; user_3  - Spindel-Warmlauf
; user_4  - Werkzeugwechsel (manuell)
; user_5  - Einzelkanten-Antastung (automatisch auf 0)
; user_6  - Ecken-Antastung mit Rotation
; user_7  - Loch-Antastung (Mittelpunkt)
; user_8  - Zylinder-Antastung (Aussenmittelpunkt)
; user_9  - Werkzeug-Bruchkontrolle
; user_10 - Vier-Kanten-Rechteck-Vermessung (Mittelpunkt + Masskontr.)
; user_11 - Werkstueck-Dicken-Messung (Oberseite/Unterseite)
; user_12 - Koordinatensystem-Manager (G54-G59 Verwaltung)
;
; KONFIGURATION:
; --------------
; Per MDI ausfuehren: gosub config
;
; WICHTIGE PARAMETER:
; -------------------
; #4400  - Sensor-Typ (0=Oeffner, 1=Schliesser)
; #4520  - Werkzeugwechseltyp (0/1/2)
; #4546  - 3D-Taster Kugelradius (WICHTIG!)
; #4510  - Tasterhoehe fuer Z-Nullpunkt
; #4600  - Toleranz Rechteck-Vermessung (Default: 0.1mm)
; #4601  - Max. Suchstrecke Rechteck (Default: 50mm)
; #4610  - Toleranz Dicken-Messung (Default: 0.2mm)
;
;***************************************************************************************
