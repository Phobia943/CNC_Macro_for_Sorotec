#!/bin/bash

################################################################################
# Sorotec Eding CNC Macro V3.6 - Linux/Unix Installer
# Für Eding CNC unter Linux (z.B. via Wine)
################################################################################

SCRIPT_VERSION="3.6"
SCRIPT_NAME="Sorotec Eding CNC Macro"

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Typische Eding CNC Pfade (Linux/Wine)
EDING_PATHS=(
    "$HOME/.wine/drive_c/Program Files/EdingCNC"
    "$HOME/.wine/drive_c/Program Files (x86)/EdingCNC"
    "$HOME/.wine/drive_c/EdingCNC"
    "/opt/EdingCNC"
    "$HOME/EdingCNC"
)

################################################################################
# FUNKTIONEN
################################################################################

print_banner() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║                                                                ║${RESET}"
    echo -e "${CYAN}║        SOROTEC EDING CNC MACRO V${SCRIPT_VERSION} - INSTALLER             ║${RESET}"
    echo -e "${CYAN}║                                                                ║${RESET}"
    echo -e "${CYAN}║           Automatische Installation (Linux/Unix)               ║${RESET}"
    echo -e "${CYAN}║                                                                ║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${RESET} $1"
}

print_error() {
    echo -e "${RED}✗${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${RESET} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${RESET} $1"
}

print_step() {
    echo ""
    echo -e "${MAGENTA}▶${RESET} $1"
}

find_eding_cnc() {
    print_step "Suche Eding CNC Installation..."

    for path in "${EDING_PATHS[@]}"; do
        if [ -d "$path" ]; then
            print_success "Gefunden: $path"
            echo "$path"
            return 0
        fi
    done

    print_warning "Eding CNC nicht in Standard-Pfaden gefunden"
    echo ""
    echo -n "Bitte geben Sie den Eding CNC Installationspfad ein (oder leer lassen zum Abbrechen): "
    read custom_path

    if [ -z "$custom_path" ]; then
        print_error "Installation abgebrochen"
        exit 1
    fi

    if [ -d "$custom_path" ]; then
        print_success "Benutzerdefinierter Pfad akzeptiert: $custom_path"
        echo "$custom_path"
        return 0
    else
        print_error "Pfad nicht gefunden: $custom_path"
        exit 1
    fi
}

create_backup() {
    local source_file="$1"
    local backup_dir="$2"

    if [ -f "$source_file" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local filename=$(basename "$source_file")
        local backup_file="${backup_dir}/${filename}.backup_${timestamp}"

        cp "$source_file" "$backup_file" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Backup erstellt: $backup_file"
            return 0
        else
            print_error "Fehler beim Erstellen des Backups"
            return 1
        fi
    else
        print_info "Keine existierende Datei zum Backup gefunden"
        return 0
    fi
}

install_macro() {
    local eding_path="$1"
    local source_path="$2"

    print_step "Installiere Macro..."

    # Backup-Verzeichnis erstellen
    local backup_dir="${eding_path}/backups"
    mkdir -p "$backup_dir"
    print_info "Backup-Verzeichnis: $backup_dir"

    # Config-Verzeichnis erstellen (falls nicht vorhanden)
    local config_dir="${eding_path}/config"
    mkdir -p "$config_dir"
    print_info "Config-Verzeichnis: $config_dir"

    # Macro-Pfade (KORREKT: config/macro.cnc)
    local macro_source="${source_path}/macro.cnc"
    local macro_target="${config_dir}/macro.cnc"

    if [ ! -f "$macro_source" ]; then
        print_error "Macro-Datei nicht gefunden: $macro_source"
        return 1
    fi

    # Backup erstellen
    if [ -f "$macro_target" ]; then
        create_backup "$macro_target" "$backup_dir"
        if [ $? -ne 0 ]; then
            print_error "Backup fehlgeschlagen. Installation abgebrochen."
            return 1
        fi
    fi

    # Macro kopieren
    cp "$macro_source" "$macro_target"
    if [ $? -eq 0 ]; then
        print_success "Macro installiert: $macro_target"

        # Dateigröße anzeigen
        local filesize=$(du -h "$macro_target" | cut -f1)
        print_info "Dateigröße: $filesize"

        # Macro-Konfigurationsdateien kopieren (für Tooltips/Namen)
        local config_files=(
            "user_macro_names.txt"
            "user_macro_tooltips.txt"
            "user_macros.ini"
        )

        local config_copied=0
        for config_file in "${config_files[@]}"; do
            local config_source="${source_path}/${config_file}"
            if [ -f "$config_source" ]; then
                cp "$config_source" "$config_dir/"
                if [ $? -eq 0 ]; then
                    ((config_copied++))
                fi
            fi
        done

        if [ $config_copied -gt 0 ]; then
            print_success "Macro-Konfiguration installiert ($config_copied Dateien)"
        fi

        return 0
    else
        print_error "Fehler beim Kopieren des Macros"
        return 1
    fi
}

install_icons() {
    local eding_path="$1"
    local source_path="$2"

    print_step "Installiere Icons..."

    local icons_source="${source_path}/icons"
    # KORREKT: icons/op_f_key/user/
    local icons_target="${eding_path}/icons/op_f_key/user"

    if [ ! -d "$icons_source" ]; then
        print_warning "Icons-Verzeichnis nicht gefunden: $icons_source"
        print_info "Icons werden übersprungen"
        return 0
    fi

    # Icons-Verzeichnis erstellen (inkl. Unterverzeichnisse)
    mkdir -p "$icons_target"
    print_info "Icons-Verzeichnis: $icons_target"

    # Backup von existierenden Icons
    local backup_dir="${eding_path}/backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local icons_backup="${backup_dir}/icons_backup_${timestamp}"

    if [ -d "$icons_target" ] && [ "$(ls -A $icons_target 2>/dev/null)" ]; then
        cp -r "$icons_target" "$icons_backup" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Icons-Backup erstellt: $icons_backup"
        else
            print_warning "Icons-Backup fehlgeschlagen"
        fi
    fi

    # SVG Icons kopieren
    local copied_count=0
    for icon in "$icons_source"/*.svg; do
        if [ -f "$icon" ]; then
            cp "$icon" "$icons_target/"
            if [ $? -eq 0 ]; then
                ((copied_count++))
            fi
        fi
    done

    if [ $copied_count -gt 0 ]; then
        print_success "$copied_count SVG Icons installiert"
    else
        print_warning "Keine SVG Icons kopiert"
    fi

    # BMP Icons kopieren (aus icons/bmp/)
    local bmp_source="${icons_source}/bmp"
    if [ -d "$bmp_source" ]; then
        local bmp_count=0
        for bmp in "$bmp_source"/*.bmp; do
            if [ -f "$bmp" ]; then
                cp "$bmp" "$icons_target/"
                if [ $? -eq 0 ]; then
                    ((bmp_count++))
                fi
            fi
        done
        if [ $bmp_count -gt 0 ]; then
            print_success "$bmp_count BMP Icons installiert (UX.bmp Format)"
        fi
    else
        print_info "Keine BMP Icons gefunden (optional)"
    fi

    # Dokumentation kopieren
    cp "$icons_source"/*.md "$icons_target/" 2>/dev/null
    cp "$icons_source"/*.html "$icons_target/" 2>/dev/null
    print_info "Icon-Dokumentation kopiert"

    return 0
}

install_documentation() {
    local eding_path="$1"
    local source_path="$2"

    print_step "Installiere Dokumentation..."

    local docs_target="${eding_path}/docs"
    mkdir -p "$docs_target"

    local doc_files=(
        "README.md"
        "FEATURE_COMPARISON_MATRIX.md"
        "QUICK_COMPARISON_SUMMARY.md"
    )

    local copied_count=0
    for doc_file in "${doc_files[@]}"; do
        local source_file="${source_path}/${doc_file}"
        if [ -f "$source_file" ]; then
            cp "$source_file" "$docs_target/"
            if [ $? -eq 0 ]; then
                ((copied_count++))
            fi
        fi
    done

    if [ $copied_count -gt 0 ]; then
        print_success "$copied_count Dokumentations-Dateien installiert"
    fi

    return 0
}

show_summary() {
    local eding_path="$1"
    local macro_installed="$2"
    local icons_installed="$3"

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║                 INSTALLATION ABGESCHLOSSEN                     ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""

    print_info "Installationspfad: $eding_path"
    echo ""

    if [ "$macro_installed" = "1" ]; then
        print_success "Macro installiert: ${eding_path}/config/macro.cnc"
    else
        print_error "Macro NICHT installiert"
    fi

    if [ "$icons_installed" = "1" ]; then
        print_success "Icons installiert: ${eding_path}/icons/op_f_key/user/"
    else
        print_warning "Icons NICHT installiert"
    fi

    echo ""
    print_info "Backups gespeichert in: ${eding_path}/backups/"
    echo ""

    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${YELLOW}  NÄCHSTE SCHRITTE:${RESET}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo "  1. Starten Sie Eding CNC neu"
    echo "  2. Prüfen Sie, ob das Macro geladen wurde"
    echo "  3. Testen Sie die Funktionen vorsichtig!"
    echo "  4. Lesen Sie die Dokumentation in: ${eding_path}/docs/"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${RESET}"
    echo ""
}

confirm_installation() {
    echo ""
    print_warning "WARNUNG: Existierende Macro-Dateien werden überschrieben!"
    print_info "Ein Backup wird automatisch erstellt."
    echo ""

    echo -n "Möchten Sie fortfahren? (j/n): "
    read response

    if [ "$response" = "j" ] || [ "$response" = "J" ] || [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        return 0
    else
        return 1
    fi
}

################################################################################
# HAUPTPROGRAMM
################################################################################

print_banner

# Prüfe ob Script mit root läuft (nicht empfohlen für Wine-Installation)
if [ "$EUID" -eq 0 ]; then
    print_warning "Script läuft als root. Für Wine-Installationen nicht empfohlen!"
    echo -n "Trotzdem fortfahren? (j/n): "
    read response
    if [ "$response" != "j" ] && [ "$response" != "J" ]; then
        exit 0
    fi
fi

# Aktuelles Verzeichnis
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_info "Script-Verzeichnis: $script_path"

# Prüfe ob macro.cnc existiert
macro_path="${script_path}/macro.cnc"
if [ ! -f "$macro_path" ]; then
    print_error "FEHLER: macro.cnc nicht gefunden in: $script_path"
    print_error "Bitte führen Sie das Script aus dem Macro-Verzeichnis aus!"
    echo ""
    exit 1
fi

# Eding CNC finden
eding_path=$(find_eding_cnc)

# Bestätigung
if ! confirm_installation; then
    print_warning "Installation abgebrochen vom Benutzer"
    exit 0
fi

# Installation durchführen
install_macro "$eding_path" "$script_path"
macro_success=$?

install_icons "$eding_path" "$script_path"
icons_success=$?

install_documentation "$eding_path" "$script_path"

# Zusammenfassung
show_summary "$eding_path" "$macro_success" "$icons_success"

# Beenden mit entsprechendem Exit-Code
if [ $macro_success -eq 0 ]; then
    exit 0
else
    exit 1
fi
