import argparse
import colorsys
import configparser
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

from paths import (
    APPLY_THEME_SCRIPT,
    CONFIG_DIR,
    QUICKSHELL_COLORS,
    QUICKSHELL_PATHS,
    SCRIPTS_DIR,
    THEME_JSON,
    THEME_MACOS_JSON,
    WALLPAPERS_DIR,
    HYPRPAPER_CONFIG,
    HYPRLOCK_CONFIG,
    file_uri,
)


def write_text(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)


def load_theme():
    # macOS uses its own wallpaper-derived theme, not the shared Linux one
    theme_path = THEME_MACOS_JSON if sys.platform == "darwin" else THEME_JSON
    try:
        return json.loads(theme_path.read_text())
    except FileNotFoundError:
        print(f"Theme file not found: {theme_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Theme file is corrupt: {theme_path}: {e}", file=sys.stderr)
        sys.exit(1)


def hex_to_rgb_tuple(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def hex_to_rgb_hypr(hex_color):
    return f"rgb({hex_color.lstrip('#')})"


def sketchybar_hex(hex_color, alpha="ff"):
    return f"0x{alpha}{hex_color.lstrip('#')}"


def generate_css(colors):
    css_content = "/* Auto-generated colors */\n"
    for k, v in colors.items():
        css_content += f"@define-color {k} {v};\n"
        if k in ["surface", "base", "mantle"]:
            r, g, b = hex_to_rgb_tuple(v)
            css_content += f"@define-color {k}_alpha rgba({r}, {g}, {b}, 0.95);\n"

    # Generate CSS files
    target_dirs = ["wofi"]
    for d in target_dirs:
        write_text(CONFIG_DIR / d / "colors.css", css_content)


def generate_kitty(colors):
    kitty_colors = {
        "foreground": colors["text"],
        "background": colors["surface"],
        "selection_foreground": colors["surface"],
        "selection_background": colors["purple"],
        "cursor": colors["peach"],
        "cursor_text_color": colors["surface"],
        "url_color": colors["yellow"],
        "active_border_color": colors["peach"],
        "inactive_border_color": colors["muted"],
        "bell_border_color": colors["yellow"],
        "active_tab_foreground": colors["surface"],
        "active_tab_background": colors["peach"],
        "inactive_tab_foreground": colors["text"],
        "inactive_tab_background": colors["mantle"],
        "tab_bar_background": colors["mantle"],
        "mark1_foreground": colors["surface"],
        "mark1_background": colors["blue"],
        "mark2_foreground": colors["surface"],
        "mark2_background": colors["purple"],
        "mark3_foreground": colors["surface"],
        "mark3_background": colors["yellow"],
        "color0": colors["surface"],
        "color8": colors["muted"],
        "color1": colors["red"],
        "color9": colors["rose"],
        "color2": colors["green"],
        "color10": colors["light_green"],
        "color3": colors["yellow"],
        "color11": colors["light_peach"],
        "color4": colors["blue"],
        "color12": colors["light_blue"],
        "color5": colors["purple"],
        "color13": colors["light_purple"],
        "color6": colors["cyan"],
        "color14": colors["light_cyan"],
        "color7": colors["text"],
        "color15": colors["white"],
    }

    content = "# Auto-generated kitty colors\n"
    for k, v in kitty_colors.items():
        content += f"{k:24} {v}\n"

    write_text(CONFIG_DIR / "kitty" / "colors.conf", content)


def generate_hyprland(colors):
    content = "# Auto-generated hyprland colors\n"
    for k, v in colors.items():
        # define both rgb(hex) and raw hex (without #) for rgba appending
        content += f"${k} = {hex_to_rgb_hypr(v)}\n"
        content += f"${k}Alpha = {v.lstrip('#')}\n"

    write_text(CONFIG_DIR / "hypr" / "colors.conf", content)

    # Generate colors.lua
    lua_content = "-- Auto-generated hyprland colors\nreturn {\n"
    for k, v in colors.items():
        lua_content += f'  {k} = "{v.lstrip("#")}",\n'
    lua_content += "}\n"
    write_text(CONFIG_DIR / "hypr" / "colors.lua", lua_content)


def update_dunstrc(colors):
    dunstrc_path = CONFIG_DIR / "dunst" / "dunstrc"
    if not dunstrc_path.exists():
        return
    content = dunstrc_path.read_text()

    content = re.sub(
        r'frame_color = ".*?"(?=\nseparator_color)',
        f'frame_color = "{colors["muted"]}"',
        content,
    )

    content = re.sub(
        r'(\[urgency_low\][^\[]*?background = )".*?"',
        f'\\g<1>"{colors["surface"]}"',
        content,
    )
    content = re.sub(
        r'(\[urgency_low\][^\[]*?foreground = )".*?"',
        f'\\g<1>"{colors["text"]}"',
        content,
    )
    content = re.sub(
        r'(\[urgency_low\][^\[]*?frame_color = )".*?"',
        f'\\g<1>"{colors["blue"]}"',
        content,
    )

    content = re.sub(
        r'(\[urgency_normal\][^\[]*?background = )".*?"',
        f'\\g<1>"{colors["surface"]}"',
        content,
    )
    content = re.sub(
        r'(\[urgency_normal\][^\[]*?foreground = )".*?"',
        f'\\g<1>"{colors["text"]}"',
        content,
    )
    content = re.sub(
        r'(\[urgency_normal\][^\[]*?frame_color = )".*?"',
        f'\\g<1>"{colors["purple"]}"',
        content,
    )

    content = re.sub(
        r'(\[urgency_critical\][^\[]*?background = )".*?"',
        f'\\g<1>"{colors["surface"]}"',
        content,
    )
    content = re.sub(
        r'(\[urgency_critical\][^\[]*?foreground = )".*?"',
        f'\\g<1>"{colors["text"]}"',
        content,
    )
    content = re.sub(
        r'(\[urgency_critical\][^\[]*?frame_color = )".*?"',
        f'\\g<1>"{colors["red"]}"',
        content,
    )

    write_text(dunstrc_path, content)


def generate_spicetify(colors):
    spicetify_dir = CONFIG_DIR / "spicetify" / "Themes" / "Comfy"

    # Needs hex codes without the leading #
    s_colors = {k: v.lstrip("#") for k, v in colors.items()}

    content = f"""[Twilight-Sunset]
text               = {s_colors['text']}
subtext            = {s_colors['purple']}
main               = {s_colors['surface']}
sidebar            = {s_colors['mantle']}
player             = {s_colors['mantle']}
card               = {s_colors['base']}
shadow             = {s_colors['base']}
selected-row       = {s_colors['purple']}
button             = {s_colors['peach']}
button-active      = {s_colors['peach']}
button-disabled    = {s_colors['muted']}
tab-active         = {s_colors['purple']}
notification       = {s_colors['surface']}
notification-error = {s_colors['red']}
misc               = {s_colors['blue']}
"""
    write_text(spicetify_dir / "color.ini", content)


def generate_nvim(colors):
    nvim_colors_path = CONFIG_DIR / "nvim" / "lua" / "theme_colors.lua"
    content = "-- Auto-generated nvim colors\n"
    content += "return {\n"
    for k, v in colors.items():
        content += f'  {k} = "{v}",\n'
    content += "}\n"
    write_text(nvim_colors_path, content)


def get_firefox_base_dir():
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support" / "Firefox"

    config_base = Path.home() / ".config" / "mozilla" / "firefox"
    if config_base.exists():
        return config_base
    return Path.home() / ".mozilla" / "firefox"


def find_firefox_profile(base_dir):
    profiles_ini_path = base_dir / "profiles.ini"
    if profiles_ini_path.exists():
        config = configparser.ConfigParser()
        config.read(profiles_ini_path)
        for section in config.sections():
            if config.has_option(section, "Path") and "default-release" in config.get(
                section, "Path"
            ):
                path_val = config.get(section, "Path")
                is_relative = config.get(section, "IsRelative", fallback="1")
                if is_relative == "1":
                    return base_dir / path_val
                else:
                    return Path(path_val)

    return next(base_dir.glob("*.default-release"), None)


def generate_firefox(colors):
    profile_dir = find_firefox_profile(get_firefox_base_dir())
    if not profile_dir:
        return

    textfox_chrome_dir = profile_dir / "chrome"

    if not textfox_chrome_dir.exists():
        return

    config_path = textfox_chrome_dir / "config.css"

    css_content = "/* Auto-generated textfox colors */\n"
    css_content += ":root {\n"

    # Textfox mappings
    # Using textfox's expected tf- variables
    css_content += f"  --tf-bg: {colors['base']};\n"
    css_content += f"  --tf-accent: {colors['purple']};\n"
    css_content += f"  --tf-border: {colors['surface']};\n"
    css_content += f"  --color: {colors['text']};\n"
    css_content += f"  --identity-icon-color: {colors['text']};\n"
    css_content += f"  --identity-tab-color: {colors['purple']};\n"

    css_content += "}\n"

    write_text(config_path, css_content)


def generate_gtk(colors):
    # GTK3/4 and Libadwaita standard color overrides
    css_content = f"""/* Auto-generated GTK colors */
@define-color accent_color {colors['purple']};
@define-color accent_bg_color {colors['purple']};
@define-color accent_fg_color {colors['base']};

@define-color window_bg_color {colors['base']};
@define-color window_fg_color {colors['text']};
@define-color view_bg_color {colors['mantle']};
@define-color view_fg_color {colors['text']};

@define-color headerbar_bg_color {colors['surface']};
@define-color headerbar_fg_color {colors['text']};
@define-color headerbar_border_color {colors['muted']};
@define-color headerbar_backdrop_color {colors['base']};
@define-color headerbar_shade_color rgba(0, 0, 0, 0.36);

@define-color popover_bg_color {colors['surface']};
@define-color popover_fg_color {colors['text']};
@define-color card_bg_color {colors['surface']};
@define-color card_fg_color {colors['text']};
@define-color dialog_bg_color {colors['base']};
@define-color dialog_fg_color {colors['text']};

@define-color theme_bg_color {colors['base']};
@define-color theme_fg_color {colors['text']};
@define-color theme_base_color {colors['mantle']};
@define-color theme_text_color {colors['text']};

@define-color error_color {colors['red']};
@define-color warning_color {colors['yellow']};
@define-color success_color {colors['green']};
@define-color destructive_color {colors['red']};
    """
    # Write to both GTK 3.0 and GTK 4.0
    for gtk_ver in ["gtk-3.0", "gtk-4.0"]:
        gtk_dir = Path.home() / ".config" / gtk_ver
        write_text(gtk_dir / "gtk.css", css_content)


def generate_qt(colors):
    c = {k: f"#ff{v.lstrip('#')}" for k, v in colors.items()}
    c_muted = f"#80{colors['text'].lstrip('#')}"
    qt_colors = (
        c["text"],
        c["surface"],
        c["surface"],
        c["mantle"],
        c["mantle"],
        c["mantle"],
        c["text"],
        c["white"],
        c["text"],
        c["base"],
        c["base"],
        c["mantle"],
        c["purple"],
        c["base"],
        c["blue"],
        c["purple"],
        c["surface"],
        c["text"],
        c["mantle"],
        c["text"],
        c_muted,
    )
    color_str = ", ".join(qt_colors)
    conf_content = f"[ColorScheme]\nactive_colors={color_str}\ndisabled_colors={color_str}\ninactive_colors={color_str}\n"

    for qt_ver in ["qt5ct", "qt6ct"]:
        colors_dir = Path.home() / ".config" / qt_ver / "colors"
        write_text(colors_dir / "pywal.conf", conf_content)

        qt_conf_path = Path.home() / ".config" / qt_ver / f"{qt_ver}.conf"
        config = configparser.ConfigParser()
        config.optionxform = str

        if qt_conf_path.exists():
            config.read(qt_conf_path)

        if not config.has_section("Appearance"):
            config.add_section("Appearance")

        config.set(
            "Appearance",
            "color_scheme_path",
            str(colors_dir / "pywal.conf"),
        )
        config.set("Appearance", "custom_palette", "true")
        config.set("Appearance", "style", "Fusion")

        qt_conf_path.parent.mkdir(parents=True, exist_ok=True)
        with open(qt_conf_path, "w") as f:
            config.write(f)


def generate_quickshell(colors):
    content = "/* Auto-generated quickshell colors */\n"
    content += "import QtQuick\n\n"
    content += "QtObject {\n"
    for k, v in colors.items():
        content += f'    property color {k}: "{v}"\n'

    content += "\n    function reload() {\n"
    content += "        var xhr = new XMLHttpRequest();\n"
    content += f'        xhr.open("GET", "{file_uri(THEME_JSON)}?t=" + Date.now());\n'
    content += "        xhr.onreadystatechange = function() {\n"
    content += "            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {\n"
    content += "                try {\n"
    content += "                    var c = JSON.parse(xhr.responseText);\n"
    for k in colors.keys():
        content += f"                    if (c.{k} !== undefined) {k} = c.{k};\n"
    content += "                } catch (e) {\n"
    content += '                    console.log("Failed to parse theme.json:", e);\n'
    content += "                }\n"
    content += "            }\n"
    content += "        };\n"
    content += "        xhr.send();\n"
    content += "    }\n"
    content += "}\n"

    write_text(QUICKSHELL_COLORS, content)


def generate_quickshell_paths():
    content = f"""/* Auto-generated quickshell paths */
import QtQuick

QtObject {{
    readonly property string hyprpaperConfigPath: "{HYPRPAPER_CONFIG}"
    readonly property string setWallpaperScriptPath: "{APPLY_THEME_SCRIPT}"
    readonly property string wallpaperFolderUrl: "{file_uri(WALLPAPERS_DIR)}"
}}
"""

    write_text(QUICKSHELL_PATHS, content)


def generate_sketchybar(colors):
    # macOS only: sourced by sketchybarrc, sketchybar wants 0xAARRGGBB
    lines = ["# Auto-generated sketchybar colors - do not edit, run apply_theme.py", "# NOTE: theme-macos.json is wallpaper-derived; names are approximate (green is dusty rose, purple is sage)"]
    lines.append(f'BAR_BG="{sketchybar_hex(colors["mantle"])}"')
    lines.append(f'BAR_BG_DIM="0x66{colors["surface"].lstrip("#")}"')
    lines.append(f'TEXT="{sketchybar_hex(colors["text"])}"')
    lines.append(f'DARK="{sketchybar_hex(colors["mantle"])}"')
    lines.append(f'GREEN="{sketchybar_hex(colors["green"])}"')
    lines.append(f'BLUE="{sketchybar_hex(colors["blue"])}"')
    lines.append(f'RED="{sketchybar_hex(colors["red"])}"')
    lines.append(f'PEACH="{sketchybar_hex(colors["peach"])}"')
    lines.append(f'PURPLE="{sketchybar_hex(colors["purple"])}"')
    write_text(CONFIG_DIR / "sketchybar" / "colors.sh", "\n".join(lines) + "\n")


def generate_yabai(colors):
    # yabairc sources this generated file; never rewrite the tracked yabairc
    accent = '0xff' + colors['peach'].lstrip('#')
    lines = [
        "# Auto-generated yabai colors - do not edit, run apply_theme.py",
        f'YABAI_INSERT_FEEDBACK_COLOR="{accent}"',
    ]
    write_text(CONFIG_DIR / "yabai" / "colors.sh", "\n".join(lines) + "\n")


def apply_borders_macos():
    # JankyBorders only reads colors at launch, so restart it via the wrapper
    script = SCRIPTS_DIR / "start-borders.sh"
    subprocess.run([str(script)])


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


def hex_to_hls(hex_color):
    hex_color = hex_color.lstrip("#")
    r, g, b = tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))
    return colorsys.rgb_to_hls(r / 255.0, g / 255.0, b / 255.0)


def hls_to_hex(h, l, s):
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return "#{:02x}{:02x}{:02x}".format(int(r * 255), int(g * 255), int(b * 255))


def adjust_color(hex_color, target_l, max_s=0.20):
    """Pin lightness, cap saturation so backgrounds don't get garish."""
    h, _, s = hex_to_hls(hex_color)
    s = min(s, max_s)
    return hls_to_hex(h, target_l, s)


def ensure_readability(hex_color, min_l=0.65, min_s=0.40, max_s=0.85):
    """Keep accents bright enough for dark backgrounds without oversaturating."""
    h, _, s = hex_to_hls(hex_color)
    l = max(l, min_l)
    s = max(min_s, min(s, max_s))
    return hls_to_hex(h, l, s)


def generate_theme_from_wallpaper(wallpaper_path):
    """Run pywal on the wallpaper and write the curated theme.json."""
    # Run pywal; abort on failure so we never theme from a stale colors.json
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
        print("Could not find Pywal colors. Make sure 'wal' is installed and ran successfully.")
        sys.exit(1)

    bg_color = wal["special"]["background"]
    mantle = adjust_color(bg_color, target_l=0.09, max_s=0.10)
    base = adjust_color(bg_color, target_l=0.12, max_s=0.10)
    surface = adjust_color(bg_color, target_l=0.17, max_s=0.10)

    my_theme = {
        "base": base,
        "mantle": mantle,
        "surface": surface,
        "text": wal["special"]["foreground"],
        "muted": adjust_color(wal["colors"]["color8"], target_l=0.45, max_s=0.15),
        "white": wal["colors"]["color15"],
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

    theme_out = THEME_MACOS_JSON if sys.platform == "darwin" else THEME_JSON
    with open(theme_out, "w") as f:
        json.dump(my_theme, f, indent=2)

    print(f"Theme generated from {os.path.basename(wallpaper_path)}!")
    print(f"Base BG: {base}, Mantle: {mantle}, Surface: {surface}")


def set_wallpaper(wallpaper_path):
    """Set the platform wallpaper. Runs after theme generation so they never desync."""
    print(f"Setting wallpaper to {wallpaper_path}...")
    if sys.platform == "darwin":
        result = subprocess.run(
            [
                "osascript",
                "-e",
                f'tell application "System Events" to set picture of every desktop to "{wallpaper_path}"',
            ],
            capture_output=True,
        )
        if result.returncode != 0:
            print("Warning: failed to set macOS wallpaper.")
        return
    # Linux
    if os.environ.get("XDG_CURRENT_DESKTOP") == "KDE":
        print("Running under KDE, applying wallpaper using plasma-apply-wallpaperimage...")
        subprocess.run(["plasma-apply-wallpaperimage", wallpaper_path], capture_output=True)
        return
    # Hyprland (hyprctl fails gracefully when Hyprland is not running)
    for args in (
        ["hyprctl", "hyprpaper", "preload", wallpaper_path],
        ["hyprctl", "hyprpaper", "wallpaper", f",{wallpaper_path}"],
        ["hyprctl", "hyprpaper", "unload", "all"],
    ):
        subprocess.run(args, capture_output=True)
    HYPRPAPER_CONFIG.write_text(
        f"""splash = false
ipc = on

preload = {wallpaper_path}

wallpaper {{
    monitor =
    path = {wallpaper_path}
    fit_mode = cover
}}
"""
    )
    # Sync wallpaper to Hyprlock config background path
    text = HYPRLOCK_CONFIG.read_text()
    text = re.sub(r"^(    path = ).*$", rf"\g<1>{wallpaper_path}", text, flags=re.MULTILINE)
    HYPRLOCK_CONFIG.write_text(text)


# --- Linux theme application -------------------------------------------------
# apply_theme.py is the Linux "apply theme": after generating the color files
# it reloads the running apps so they pick up the new theme without a
# wallpaper change.


def _ancestor_is_quickshell():
    # apply_theme.py may run from quickshell's WallpaperSwitcher, which
    # reloads colors dynamically; restarting would kill the caller.
    pid = os.getpid()
    while pid > 1:
        try:
            comm = Path(f"/proc/{pid}/comm").read_text().strip()
        except OSError:
            return False
        if comm == "quickshell":
            return True
        try:
            # /proc/pid/stat: pid (comm) state ppid ...
            after_comm = Path(f"/proc/{pid}/stat").read_text().rsplit(")", 1)[1].split()
            pid = int(after_comm[1])
        except (OSError, ValueError, IndexError):
            return False
    return False


def reload_hyprland():
    if shutil.which("hyprctl"):
        subprocess.run(["hyprctl", "reload"], capture_output=True)


def reload_quickshell():
    if _ancestor_is_quickshell():
        print("Wallpaper changed from within quickshell; reloading colors dynamically.")
        return
    if not shutil.which("quickshell"):
        return
    subprocess.run(["killall", "quickshell"], capture_output=True)
    for _ in range(50):
        if subprocess.run(["pgrep", "-x", "quickshell"], capture_output=True).returncode != 0:
            break
        time.sleep(0.1)
    subprocess.Popen(
        ["quickshell"],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def reload_kitty():
    # load-config pushes the regenerated colors.conf to running instances.
    if shutil.which("kitty"):
        subprocess.run(["kitty", "@", "load-config"], capture_output=True)


def reload_dunst():
    # dunst has no reload; restart it to pick up the rewritten dunstrc.
    if shutil.which("dunst") and shutil.which("pgrep"):
        if subprocess.run(["pgrep", "-x", "dunst"], capture_output=True).returncode == 0:
            subprocess.run(["killall", "dunst"], capture_output=True)
            subprocess.Popen(
                ["dunst"],
                start_new_session=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )


def reload_spicetify():
    # Applies color.ini; restarts Spotify if it is running.
    if shutil.which("spicetify"):
        subprocess.run(["spicetify", "apply"], capture_output=True)


def main():
    parser = argparse.ArgumentParser(description="Generate and apply the wallpaper-derived theme")
    parser.add_argument("wallpaper", nargs="?", help="Wallpaper image to theme from and set")
    args = parser.parse_args()

    if args.wallpaper:
        wallpaper_path = os.path.realpath(args.wallpaper)
        if not os.path.isfile(wallpaper_path):
            print(f"Error: File {wallpaper_path} not found.")
            sys.exit(1)
        # Generate theme first; abort before touching the wallpaper on failure
        generate_theme_from_wallpaper(wallpaper_path)

    colors = load_theme()
    if sys.platform == "darwin":
        # Only macOS surfaces; shared generated files keep the Linux theme
        generate_sketchybar(colors)
        generate_yabai(colors)
        apply_borders_macos()
        if shutil.which("sketchybar"):
            subprocess.run(["sketchybar", "--reload"])
        print("Successfully generated macOS color configs!")
        return
    generate_css(colors)
    generate_kitty(colors)
    generate_hyprland(colors)
    update_dunstrc(colors)
    generate_spicetify(colors)
    generate_nvim(colors)
    generate_firefox(colors)
    generate_gtk(colors)
    generate_qt(colors)
    generate_quickshell(colors)
    generate_quickshell_paths()
    # Apply to running apps
    reload_hyprland()
    reload_quickshell()
    reload_kitty()
    reload_dunst()
    reload_spicetify()
    if args.wallpaper:
        set_wallpaper(wallpaper_path)
    print("Successfully generated and applied color configs!")


if __name__ == "__main__":
    main()
