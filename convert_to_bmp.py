#!/usr/bin/env python3
"""
SVG zu BMP Konverter für Eding CNC Icons
Konvertiert die SVG-Icons in BMP-Format und benennt sie nach UX.bmp Schema
"""

import os
import sys
from pathlib import Path

# Icon-Mapping: SVG-Dateiname -> BMP-Dateiname
ICON_MAPPING = {
    "user_1_tool_length.svg": "U1.bmp",
    "user_2_z_zero.svg": "U2.bmp",
    "user_3_spindle_warmup.svg": "U3.bmp",
    "user_4_tool_change.svg": "U4.bmp",
    "user_5_edge_probe.svg": "U5.bmp",
    "user_6_corner_rotation.svg": "U6.bmp",
    "user_7_hole_probe.svg": "U7.bmp",
    "user_8_cylinder_probe.svg": "U8.bmp",
    "user_9_break_check.svg": "U9.bmp",
    "user_10_rectangle_measure.svg": "U10.bmp",
    "user_11_thickness_measure.svg": "U11.bmp",
    "user_12_coordinate_manager.svg": "U12.bmp",
}

ICON_SIZE = 64  # Größe in Pixel

def print_banner():
    print("╔" + "═" * 64 + "╗")
    print("║" + " " * 64 + "║")
    print("║" + "    SVG → BMP KONVERTER FÜR EDING CNC".center(64) + "║")
    print("║" + " " * 64 + "║")
    print("║" + "    Konvertiert Icons nach UX.bmp Schema".center(64) + "║")
    print("║" + " " * 64 + "║")
    print("╚" + "═" * 64 + "╝")
    print()

def check_dependencies():
    """Prüft, welche Konvertierungs-Libraries verfügbar sind"""
    methods = []

    # Versuche cairosvg (beste Qualität)
    try:
        import cairosvg
        methods.append(("cairosvg", "Exzellent"))
    except ImportError:
        pass

    # Versuche PIL/Pillow mit svg2rlg
    try:
        from PIL import Image
        from svglib.svglib import svg2rlg
        from reportlab.graphics import renderPM
        methods.append(("svglib", "Sehr gut"))
    except ImportError:
        pass

    # Versuche wand (ImageMagick wrapper)
    try:
        from wand.image import Image as WandImage
        methods.append(("wand", "Gut"))
    except ImportError:
        pass

    # Versuche PIL basic
    try:
        from PIL import Image
        methods.append(("pil", "Fallback"))
    except ImportError:
        pass

    return methods

def convert_with_cairosvg(svg_path, bmp_path, size):
    """Konvertierung mit cairosvg"""
    import cairosvg
    from PIL import Image
    import io

    # SVG zu PNG (im Speicher)
    png_data = cairosvg.svg2png(url=str(svg_path), output_width=size, output_height=size)

    # PNG zu BMP
    image = Image.open(io.BytesIO(png_data))

    # Konvertiere zu RGB (BMP unterstützt kein RGBA)
    if image.mode == 'RGBA':
        # Erstelle weißen Hintergrund
        background = Image.new('RGB', image.size, (255, 255, 255))
        background.paste(image, mask=image.split()[3])  # Alpha-Kanal als Maske
        image = background

    image.save(bmp_path, 'BMP')
    return True

def convert_with_svglib(svg_path, bmp_path, size):
    """Konvertierung mit svglib"""
    from svglib.svglib import svg2rlg
    from reportlab.graphics import renderPM
    from PIL import Image
    import io

    # SVG laden
    drawing = svg2rlg(str(svg_path))

    # Zu PNG rendern (im Speicher)
    png_data = renderPM.drawToString(drawing, fmt='PNG')

    # PNG zu BMP
    image = Image.open(io.BytesIO(png_data))
    image = image.resize((size, size), Image.Resampling.LANCZOS)

    # Konvertiere zu RGB
    if image.mode == 'RGBA':
        background = Image.new('RGB', image.size, (255, 255, 255))
        background.paste(image, mask=image.split()[3])
        image = background

    image.save(bmp_path, 'BMP')
    return True

def convert_with_wand(svg_path, bmp_path, size):
    """Konvertierung mit wand (ImageMagick)"""
    from wand.image import Image as WandImage

    with WandImage(filename=str(svg_path)) as img:
        img.resize(size, size)
        img.format = 'bmp'
        img.save(filename=str(bmp_path))
    return True

def convert_with_pil_fallback(svg_path, bmp_path, size):
    """Fallback: Erstelle Placeholder BMP"""
    from PIL import Image, ImageDraw, ImageFont

    # Erstelle roten Hintergrund (Sorotec Farbe)
    image = Image.new('RGB', (size, size), (227, 6, 19))
    draw = ImageDraw.Draw(image)

    # Text hinzufügen
    text = Path(bmp_path).stem
    try:
        font = ImageFont.truetype("arial.ttf", 12)
    except:
        font = ImageFont.load_default()

    # Text zentrieren
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((size - text_width) // 2, (size - text_height) // 2)

    draw.text(position, text, fill=(255, 255, 255), font=font)

    image.save(bmp_path, 'BMP')
    return True

def main():
    print_banner()

    # Verzeichnisse
    script_dir = Path(__file__).parent
    icons_dir = script_dir / "icons"
    output_dir = icons_dir / "bmp"

    print(f"ℹ Script-Verzeichnis: {script_dir}")
    print(f"ℹ Icons-Verzeichnis: {icons_dir}")
    print(f"ℹ Output-Verzeichnis: {output_dir}")
    print()

    # Prüfe Icons-Verzeichnis
    if not icons_dir.exists():
        print(f"✗ FEHLER: Icons-Verzeichnis nicht gefunden: {icons_dir}")
        sys.exit(1)

    # Output-Verzeichnis erstellen
    output_dir.mkdir(exist_ok=True)
    print("✓ Output-Verzeichnis erstellt")
    print()

    # Prüfe verfügbare Konvertierungs-Methoden
    print("Prüfe verfügbare Konvertierungs-Bibliotheken...")
    methods = check_dependencies()

    if not methods:
        print("✗ FEHLER: Keine Konvertierungs-Bibliotheken gefunden!")
        print()
        print("Bitte installieren Sie eine der folgenden:")
        print("  pip install cairosvg pillow          (Empfohlen)")
        print("  pip install svglib pillow reportlab  (Alternative 1)")
        print("  pip install wand                     (Alternative 2)")
        print("  pip install pillow                   (Fallback)")
        sys.exit(1)

    # Zeige verfügbare Methoden
    for method, quality in methods:
        print(f"  ✓ {method:15} (Qualität: {quality})")

    # Wähle beste Methode
    best_method = methods[0][0]
    print(f"\n✓ Verwende: {best_method}")
    print()

    # Konvertierungs-Funktion wählen
    converter_map = {
        "cairosvg": convert_with_cairosvg,
        "svglib": convert_with_svglib,
        "wand": convert_with_wand,
        "pil": convert_with_pil_fallback,
    }

    converter = converter_map[best_method]

    # Konvertierung durchführen
    success_count = 0
    fail_count = 0

    for svg_file, bmp_file in ICON_MAPPING.items():
        source_path = icons_dir / svg_file
        target_path = output_dir / bmp_file

        print(f"Konvertiere: {svg_file:35} → {bmp_file:10}", end=" ")

        if not source_path.exists():
            print("[FEHLT]")
            fail_count += 1
            continue

        try:
            converter(source_path, target_path, ICON_SIZE)
            print("[OK]")
            success_count += 1
        except Exception as e:
            print(f"[FEHLER: {str(e)}]")
            fail_count += 1

    # Zusammenfassung
    print()
    print("╔" + "═" * 64 + "╗")
    print("║" + "KONVERTIERUNG ABGESCHLOSSEN".center(64) + "║")
    print("╚" + "═" * 64 + "╝")
    print()

    print(f"✓ Erfolgreich: {success_count}")
    if fail_count > 0:
        print(f"✗ Fehlgeschlagen: {fail_count}")

    print()
    print(f"ℹ BMP-Dateien gespeichert in: {output_dir}")
    print()

    print("Folgende Dateien wurden erstellt:")
    for bmp_file in sorted(output_dir.glob("*.bmp")):
        size_kb = bmp_file.stat().st_size / 1024
        print(f"  {bmp_file.name} ({size_kb:.2f} KB)")

    print()
    print("═" * 66)
    print("  NÄCHSTE SCHRITTE:")
    print("═" * 66)
    print()
    print(f"  1. Prüfen Sie die BMP-Dateien in: {output_dir}")
    print("  2. Kopieren Sie die *.bmp Dateien nach:")
    print("     C:\\EdingCNC5.3\\icons\\op_f_key\\user\\")
    print("  3. Starten Sie Eding CNC neu")
    print()
    print("═" * 66)
    print()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n✗ Abgebrochen durch Benutzer")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n✗ Unerwarteter Fehler: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
