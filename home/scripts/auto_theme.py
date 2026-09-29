import argparse
import subprocess
import glob
import json
import os
import sys
import colorsys
import shutil

from paths import APPLY_THEME_SCRIPT, THEME_JSON, THEME_MACOS_JSON

parser = argparse.ArgumentParser(
    description="Generate a curated theme.json from a wallpaper via pywal"
)
parser.add_argument(
    "--out",
    default=None,
    help="Where to write the theme (default: theme-macos.json on macOS, theme.json elsewhere)",
)
parser.add_argument("wallpaper", help="Path to wallpaper image")
args = parser.parse_args()

if args.out:
    theme_out = args.out
elif sys.platform == "darwin":
    theme_out = str(THEME_MACOS_JSON)
else:
    theme_out = str(THEME_JSON)

wallpaper_path = args.wallpaper


def wal_binary():
    # pywal user installs (pip --user) are not on PATH on macOS, and the
    # python running this script may differ from the one pywal was installed with
    found = shutil.which("wal")
    if found:
        return found
    candidates = []
    try:
        user_base = subprocess.run(
            [sys.executable, "-m", "site", "--user-base"],
            capture_output=True,
            text=True,
        ).stdout.strip()
        candidates.append(os.path.join(user_base, "bin", "wal"))
    except Exception:
        pass
    # macOS framework python user installs: ~/Library/Python/X.Y/bin
    candidates.extend(glob.glob(os.path.expanduser("~/Library/Python/*/bin/wal")))
    candidates.append(os.path.expanduser("~/.local/bin/wal"))
    for cand in candidates:
        if cand and os.path.exists(cand):
            return cand
    return "wal"


# 1. Run pywal and read outputs; abort on failure so we never theme
# from a stale colors.json left by an earlier successful run
try:
    subprocess.run([wal_binary(), "-i", wallpaper_path, "-n", "-s", "-q"], check=True)
except (subprocess.CalledProcessError, FileNotFoundError):
    print("Pywal failed to generate colors; aborting theme generation.")
    sys.exit(1)
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
    """Pin lightness, cap saturation so backgrounds don't get garish."""
    h, l, s = hex_to_hls(hex_color)
    s = min(s, max_s)
    return hls_to_hex(h, target_l, s)


def ensure_readability(hex_color, min_l=0.65, min_s=0.40, max_s=0.85):
    """Keep accents bright enough for dark backgrounds without oversaturating."""
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
with open(theme_out, "w") as f:
    json.dump(my_theme, f, indent=2)

print(f"Theme generated from {os.path.basename(wallpaper_path)}!")
print(f"Base BG: {base}, Mantle: {mantle}, Surface: {surface}")

# 5. Push configs everywhere
subprocess.run(["python3", str(APPLY_THEME_SCRIPT)])
