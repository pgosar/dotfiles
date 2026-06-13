import subprocess
import json
import os
import sys
import colorsys

if len(sys.argv) < 2:
    print("Usage: python3 auto_theme.py <path-to-wallpaper>")
    sys.exit(1)

wallpaper_path = sys.argv[1]

# 1. Run pywal and read outputs
subprocess.run(["wal", "-i", wallpaper_path, "-n", "-s", "-q"])
wal_colors_path = os.path.expanduser("~/.cache/wal/colors.json")
try:
    with open(wal_colors_path, "r") as f:
        wal = json.load(f)
except FileNotFoundError:
    print(
        "Could not find Pywal colors. Make sure 'wal' is installed and ran successfully."
    )
    sys.exit(1)


def hex_to_hls(hex_color):
    hex_color = hex_color.lstrip("#")
    r, g, b = tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))
    return colorsys.rgb_to_hls(r / 255.0, g / 255.0, b / 255.0)


def hls_to_hex(h, l, s):
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return "#{:02x}{:02x}{:02x}".format(int(r * 255), int(g * 255), int(b * 255))


def adjust_color(hex_color, target_l, max_s=0.20):
    """
    Takes a hex color and returns a new hex with the exact target lightness.
    We also cap the saturation (max_s) so backgrounds don't become garish.
    """
    h, l, s = hex_to_hls(hex_color)
    s = min(s, max_s)
    return hls_to_hex(h, target_l, s)


def ensure_readability(hex_color, min_l=0.65, min_s=0.40, max_s=0.85):
    """
    Ensures foreground colors are bright enough to be readable against dark backgrounds
    but not overly saturated so they still fit the theme.
    """
    h, l, s = hex_to_hls(hex_color)
    l = max(l, min_l)
    s = max(min_s, min(s, max_s))
    return hls_to_hex(h, l, s)


bg_color = wal["special"]["background"]

# Generate dark shades of prominent background colors
mantle = adjust_color(bg_color, target_l=0.09, max_s=0.10)
base = adjust_color(bg_color, target_l=0.12, max_s=0.10)
surface = adjust_color(bg_color, target_l=0.17, max_s=0.10)

# 2. Build theme.json
my_theme = {
    # Background Colors
    "base": base,
    "mantle": mantle,
    "surface": surface,
    # Text colors
    "text": wal["special"]["foreground"],
    "muted": adjust_color(wal["colors"]["color8"], target_l=0.45, max_s=0.15),
    "white": wal["colors"]["color15"],
    # Accents
    "red": ensure_readability(wal["colors"]["color1"]),
    "green": ensure_readability(wal["colors"]["color2"]),
    "yellow": ensure_readability(wal["colors"]["color3"]),
    "blue": ensure_readability(wal["colors"]["color4"]),
    "purple": ensure_readability(wal["colors"]["color5"]),
    "cyan": ensure_readability(wal["colors"]["color6"]),
    "rose": ensure_readability(wal["colors"]["color9"]),
    "light_green": ensure_readability(wal["colors"]["color10"]),
    "light_peach": ensure_readability(wal["colors"]["color11"]),
    "light_blue": ensure_readability(wal["colors"]["color12"]),
    "light_purple": ensure_readability(wal["colors"]["color13"]),
    "light_cyan": ensure_readability(wal["colors"]["color14"]),
    "peach": wal["colors"]["color15"],
}

# 4. Save
theme_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "theme.json")
with open(theme_file, "w") as f:
    json.dump(my_theme, f, indent=2)

print(f"Theme generated from {os.path.basename(wallpaper_path)}!")
print(f"Base BG: {base}, Mantle: {mantle}, Surface: {surface}")

# 5. Push configs everywhere
apply_script = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "apply_theme.py"
)
subprocess.run(["python3", apply_script])
