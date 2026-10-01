#!/usr/bin/env python3
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
from urllib.parse import quote

from paths import (
    APPLY_THEME_SCRIPT,
    CONFIG_DIR,
    HYPRPAPER_CONFIG,
    QUICKSHELL_COLORS,
    QUICKSHELL_PATHS,
    SCRIPTS_DIR,
    THEME_JSON,
    THEME_JSON_SEED,
    THEME_MACOS_JSON,
    THEME_MACOS_JSON_SEED,
    WALLPAPERS_DIR,
    file_uri,
)


def write_text(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)


def load_theme():
    # macOS uses its own wallpaper-derived theme, not the shared Linux one
    theme_path = THEME_MACOS_JSON if sys.platform == "darwin" else THEME_JSON
    seed_path = THEME_MACOS_JSON_SEED if sys.platform == "darwin" else THEME_JSON_SEED
    # The working copy is gitignored wallpaper state; fall back to the
    # committed seed on fresh clones.
    for path in (theme_path, seed_path):
        try:
            return json.loads(path.read_text())
        except FileNotFoundError:
            continue
        except json.JSONDecodeError as e:
            print(f"Theme file is corrupt: {path}: {e}", file=sys.stderr)
            sys.exit(1)
    print(
        f"Theme file not found: {theme_path} (seed {seed_path} also missing)",
        file=sys.stderr,
    )
    sys.exit(1)


def hex_to_rgb_tuple(hex_color):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def hex_to_rgb_hypr(hex_color):
    return f"rgb({hex_color.lstrip('#')})"


def sketchybar_hex(hex_color, alpha="ff"):
    return f"0x{alpha}{hex_color.lstrip('#')}"


def current_wallpaper():
    # Wallpaper the theme was generated from, if it still exists.
    # Platform-specific file so macOS and Linux don't clobber each other.
    filename = "wallpaper-macos.txt" if sys.platform == "darwin" else "wallpaper-linux.txt"
    try:
        path = (SCRIPTS_DIR / filename).read_text().strip()
    except OSError:
        return None
    return path if path and os.path.isfile(path) else None


def wallpaper_file_url(path):
    return "file://" + quote(path, safe="/:")


def _kitty_wallpaper_path():
    return Path.home() / ".cache" / "dotfiles" / "kitty-wallpaper.png"


def _image_mean_luminance(path):
    from PIL import Image, ImageStat  # lazy: darwin-only path

    img = Image.open(path).convert("L")
    img.thumbnail((256, 256), Image.BILINEAR)
    return ImageStat.Stat(img).mean[0] / 255


def _processed_wallpaper(wallpaper, dark, out):
    # Blurred, dimmed copy of the wallpaper. Tinting alone can't tame busy
    # wallpapers (a manga collage stays contrasty), so pre-process instead.
    from PIL import Image  # lazy: darwin-only path

    img = Image.open(wallpaper).convert("RGB")
    img.thumbnail((1920, 1920), Image.BILINEAR)  # blurred anyway; keep it small
    w, h = img.size
    smooth = img.resize((max(w // 8, 1), max(h // 8, 1)), Image.BILINEAR).resize(
        (w, h), Image.BILINEAR
    )
    if dark:
        smooth = smooth.point(lambda v: int(v * 0.4))
    else:
        # Light mode: compress to a narrow bright band. The blurred copy
        # keeps dark spots where black text gets hard to read; lifting the
        # floor to 155 keeps worst-case contrast at ~7.6:1 (WCAG AAA).
        smooth = smooth.point(lambda v: int(v * 0.08 + 155))
    out.parent.mkdir(parents=True, exist_ok=True)
    smooth.save(out)
    return out


def _kitty_wallpaper(wallpaper, dark):
    return _processed_wallpaper(wallpaper, dark, _kitty_wallpaper_path())


def _image_mean_hex(path):
    # Mean color of an image as #rrggbb; light-mode chrome tones derive here.
    from PIL import Image, ImageStat  # lazy: darwin-only path

    img = Image.open(path).convert("RGB")
    img.thumbnail((256, 256), Image.BILINEAR)
    r, g, b = (int(v) for v in ImageStat.Stat(img).mean)
    return f"#{r:02x}{g:02x}{b:02x}"


def wallpaper_is_light():
    wallpaper = current_wallpaper()
    return bool(wallpaper) and _image_mean_luminance(wallpaper) > 0.5


def _darken(hex_color, factor=0.55):
    r, g, b = hex_to_rgb_tuple(hex_color)
    return f"#{int(r * factor):02x}{int(g * factor):02x}{int(b * factor):02x}"


def _light_bg_ansi(hex_color):
    # Readable variant of a pastel ANSI color on a light background: keep the
    # wallpaper hue, but dark and saturated (body text stays near-black).
    r, g, b = hex_to_rgb_tuple(hex_color)
    h, _l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    r2, g2, b2 = colorsys.hls_to_rgb(h, 0.25, max(s, 0.6))
    return f"#{int(r2 * 255):02x}{int(g2 * 255):02x}{int(b2 * 255):02x}"


# Starship modules whose default styles wash out on light backgrounds, mapped
# to the theme colors they should be darkened from.
STARSHIP_LIGHT_STYLES = {
    "username": {"style_user": "yellow", "style_root": "red"},
    "hostname": {"style": "green"},
    "directory": {"style": "cyan"},
    "git_branch": {"style": "purple"},
    "git_status": {"style": "red"},
    "cmd_duration": {"style": "yellow"},
}


def _starship_light_toml(template, colors):
    def style_lines(module):
        return "".join(
            f'{k} = "bold {_darken(colors[ck])}"  # light wallpaper\n'
            for k, ck in STARSHIP_LIGHT_STYLES[module].items()
        )

    seen = set()
    out = []
    for line in template.splitlines(keepends=True):
        out.append(line)
        s = line.strip()
        if s.startswith("[") and s.endswith("]") and s.count("[") == 1:
            module = s[1:-1]
            if module in STARSHIP_LIGHT_STYLES:
                seen.add(module)
                out.append(style_lines(module))
    text = "".join(out)
    for module in STARSHIP_LIGHT_STYLES:
        if module not in seen:
            text += f"\n[{module}]\n{style_lines(module)}"
    return text


def generate_starship(colors):
    # install.sh symlinks ~/.config/starship.toml at the repo template; for
    # light wallpapers point it at a generated variant with darkened styles.
    template_path = CONFIG_DIR / "starship.toml"
    live_path = Path.home() / ".config" / "starship.toml"
    if wallpaper_is_light():
        cache_path = Path.home() / ".cache" / "dotfiles" / "starship-light.toml"
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        cache_path.write_text(
            _starship_light_toml(template_path.read_text(), colors)
        )
        desired = cache_path
    else:
        desired = template_path
    points_at_desired = live_path.is_symlink() and (
        live_path.parent / os.readlink(live_path)
    ).resolve() == desired.resolve()
    if not points_at_desired:
        live_path.unlink(missing_ok=True)
        live_path.symlink_to(desired)


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

    # A wallpaper can look light even when the theme is dark (manga collage),
    # so judge light/dark from the image itself, not the theme base.
    wallpaper = current_wallpaper()
    light_wallpaper = wallpaper_is_light()

    # Light-looking wallpapers get black text, whatever the theme says.
    if light_wallpaper:
        kitty_colors["foreground"] = "#000000"
        kitty_colors["color7"] = "#111111"
        kitty_colors["color15"] = "#222222"
        kitty_colors["inactive_tab_foreground"] = "#000000"
        kitty_colors["color8"] = "#666666"
        # Pastel ANSI colors wash out on a light background (e.g. the red
        # zsh-syntax-highlighting uses for unknown commands came out #c2bcb5,
        # nearly invisible); keep the hue, darken and saturate.
        for key in (
            "color1",
            "color2",
            "color3",
            "color4",
            "color5",
            "color6",
            "color9",
            "color10",
            "color11",
            "color12",
            "color13",
            "color14",
            "url_color",
        ):
            kitty_colors[key] = _light_bg_ansi(kitty_colors[key])
        # Light peach cursor disappears on a light background.
        kitty_colors["cursor"] = "#1a1a1a"
        kitty_colors["cursor_text_color"] = "#ffffff"

    content = "# Auto-generated kitty colors\n"
    for k, v in kitty_colors.items():
        content += f"{k:24} {v}\n"

    # Blurred, dimmed wallpaper behind the terminal.
    if wallpaper:
        bg_path = _kitty_wallpaper(wallpaper, dark=not light_wallpaper)
        content += f"\nbackground_image {bg_path}\n"
        content += "background_image_layout cscaled\n"

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
    # Light scheme accents: same hues, darkened for light surfaces.
    light = {k: _light_bg_ansi(v).lstrip("#") for k, v in colors.items()}

    # Light wallpaper -> Sunrise (light), dark -> Twilight-Sunset (dark).
    _is_light = _hex_luminance(colors.get("base", "#000000")) > 0.5
    _scheme = "Sunrise" if _is_light else "Twilight-Sunset"

    content = f"""[{_scheme}]
text               = {s_colors["text"]}
subtext            = {s_colors["purple"]}
main               = {s_colors["surface"]}
sidebar            = {s_colors["mantle"]}
player             = {s_colors["mantle"]}
card               = {s_colors["base"]}
shadow             = {s_colors["base"]}
selected-row       = {s_colors["purple"]}
button             = {s_colors["peach"]}
button-active      = {s_colors["peach"]}
button-disabled    = {s_colors["muted"]}
tab-active         = {s_colors["purple"]}
notification       = {s_colors["surface"]}
notification-error = {s_colors["red"]}
misc               = {s_colors["blue"]}

[Sunrise]
text               = 161616
subtext            = {light["purple"]}
main               = f2f2f2
sidebar            = e9e9e9
player             = e9e9e9
card               = ffffff
shadow             = ffffff
selected-row       = {light["purple"]}
button             = {light["peach"]}
button-active      = {light["peach"]}
button-disabled    = {light["muted"]}
tab-active         = {light["purple"]}
notification       = f2f2f2
notification-error = {light["red"]}
misc               = {light["blue"]}
"""
    write_text(spicetify_dir / "color.ini", content)

    # Follow the system theme, which tracks the wallpaper on macOS.
    if shutil.which("spicetify"):
        scheme = "Sunrise" if wallpaper_is_light() else "Twilight-Sunset"
        subprocess.run(
            ["spicetify", "config", "color_scheme", scheme],
            capture_output=True,
            check=False,
        )

    # Wallpaper behind the Spotify UI via a theme overlay.
    wallpaper = current_wallpaper()
    if wallpaper:
        # Preserve the Comfy theme's @import; append our wallpaper overlay.
        css = (
            '@import url("https://comfy-themes.github.io/Spicetify/Comfy/app.css");\n'
            "\n"
            "/* Auto-generated wallpaper background - do not edit, run apply_theme.py */\n"
            ".Root__top-container::before {\n"
            '  content: "";\n'
            "  position: absolute;\n"
            "  inset: 0;\n"
            f'  background-image: url("{wallpaper_file_url(wallpaper)}");\n'
            "  background-size: cover;\n"
            "  background-position: center;\n"
            "  opacity: 0.3;\n"
            "  pointer-events: none;\n"
            "}\n"
        )
        write_text(spicetify_dir / "user.css", css)

    # Ensure spicetify actually applies the Comfy theme.
    # If current_theme is empty, `spicetify refresh` silently does nothing.
    try:
        import configparser
        cfg_path = CONFIG_DIR / "spicetify" / "config-xpui.ini"
        cfg = configparser.ConfigParser()
        cfg.optionxform = str
        if cfg_path.exists():
            cfg.read(cfg_path)
        if not cfg.has_section("Setting"):
            cfg.add_section("Setting")
        if cfg.get("Setting", "current_theme", fallback="").strip() != "Comfy":
            cfg.set("Setting", "current_theme", "Comfy")
            with open(cfg_path, "w") as f:
                cfg.write(f)
            print("Set spicetify current_theme=Comfy")
    except Exception as e:
        print(f"Warning: could not set spicetify theme: {e}")


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

    # Wallpaper drives the chrome image and the light/dark variable set.
    wallpaper = current_wallpaper()
    light = wallpaper_is_light()

    # Webpages follow the system theme (2 = system; 0 = dark, 1 = light).
    # The macOS appearance itself is synced to the wallpaper, so pages match
    # the wallpaper's light/dark (see sync_macos_appearance).
    user_js = profile_dir / "user.js"
    existing = user_js.read_text() if user_js.exists() else ""
    lines = [
        line
        for line in existing.splitlines()
        if "prefers-color-scheme.content-override" not in line
    ]
    lines.append('user_pref("layout.css.prefers-color-scheme.content-override", 2);')
    write_text(user_js, "\n".join(lines) + "\n")

    textfox_chrome_dir = profile_dir / "chrome"

    if not textfox_chrome_dir.exists():
        return

    config_path = textfox_chrome_dir / "config.css"

    bg_path = None
    if wallpaper:
        bg_path = _processed_wallpaper(
            wallpaper,
            dark=not light,
            out=Path.home() / ".cache" / "dotfiles" / "firefox-wallpaper.png",
        )

    if light and bg_path and bg_path.is_file():
        # Light chrome: flat tones from the blurred copy's mean color, so
        # surfaces without image coverage match its average tone.
        base = _image_mean_hex(bg_path)
        tf_bg, tf_accent, tf_border, tf_text = (
            base,
            _darken(base, 0.45),
            _darken(base, 0.72),
            "#161616",
        )
    else:
        tf_bg, tf_accent, tf_border, tf_text = (
            colors["base"],
            colors["purple"],
            colors["surface"],
            colors["text"],
        )

    css_content = "/* Auto-generated textfox colors */\n"
    css_content += ":root {\n"

    # Textfox mappings
    # Using textfox's expected tf- variables
    css_content += f"  --tf-bg: {tf_bg};\n"
    css_content += f"  --tf-accent: {tf_accent};\n"
    css_content += f"  --tf-border: {tf_border};\n"
    css_content += f"  --color: {tf_text};\n"
    css_content += f"  --identity-icon-color: {tf_text};\n"
    css_content += f"  --identity-tab-color: {tf_accent};\n"

    css_content += "}\n"

    # Blurred wallpaper behind the browser chrome. Pre-blurred with
    # PIL: CSS can't blur an element's own background-image. The left strip
    # is #sidebar-select-box (textfox paints it with the dark theme accent);
    # #browser shows through the margin around the content. body covers any
    # other transparent regions.
    if bg_path and bg_path.is_file():
        bg_url = wallpaper_file_url(str(bg_path))
        css_content += (
            "\n/* Auto-generated wallpaper background */\n"
            "body, #navigator-toolbox, #sidebar-box, #sidebar-main,\n"
            "#vertical-tabs, #sidebar-select-box {\n"
            f'  background-image: url("{bg_url}") !important;\n'
            "  background-size: cover !important;\n"
            "  background-position: center !important;\n"
            "}\n"
            "/* Textfox repaints these under lightweight themes: the sidebar\n"
            "   image gets unset, and #browser gets the dark theme accent.\n"
            "   Re-assert the wallpaper with matching specificity. */\n"
            ":root[lwtheme] #sidebar-main,\n"
            ":root[lwtheme] #browser:not(.browser-toolbox-background) {\n"
            f'  background-image: url("{bg_url}") !important;\n'
            "  background-size: cover !important;\n"
            "  background-position: center !important;\n"
            "}\n"
        )

    write_text(config_path, css_content)

def generate_gtk(colors):
    # GTK3/4 and Libadwaita standard color overrides
    css_content = f"""/* Auto-generated GTK colors */
@define-color accent_color {colors["purple"]};
@define-color accent_bg_color {colors["purple"]};
@define-color accent_fg_color {colors["base"]};

@define-color window_bg_color {colors["base"]};
@define-color window_fg_color {colors["text"]};
@define-color view_bg_color {colors["mantle"]};
@define-color view_fg_color {colors["text"]};

@define-color headerbar_bg_color {colors["surface"]};
@define-color headerbar_fg_color {colors["text"]};
@define-color headerbar_border_color {colors["muted"]};
@define-color headerbar_backdrop_color {colors["base"]};
@define-color headerbar_shade_color rgba(0, 0, 0, 0.36);

@define-color popover_bg_color {colors["surface"]};
@define-color popover_fg_color {colors["text"]};
@define-color card_bg_color {colors["surface"]};
@define-color card_fg_color {colors["text"]};
@define-color dialog_bg_color {colors["base"]};
@define-color dialog_fg_color {colors["text"]};

@define-color theme_bg_color {colors["base"]};
@define-color theme_fg_color {colors["text"]};
@define-color theme_base_color {colors["mantle"]};
@define-color theme_text_color {colors["text"]};

@define-color error_color {colors["red"]};
@define-color warning_color {colors["yellow"]};
@define-color success_color {colors["green"]};
@define-color destructive_color {colors["red"]};
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
    for k in colors:
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
    lines = [
        "# Auto-generated sketchybar colors - do not edit, run apply_theme.py",
        "# NOTE: theme-macos.json is wallpaper-derived; names are approximate (green is dusty rose, purple is sage)",
    ]
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
    accent = "0xff" + colors["peach"].lstrip("#")
    lines = [
        "# Auto-generated yabai colors - do not edit, run apply_theme.py",
        f'YABAI_INSERT_FEEDBACK_COLOR="{accent}"',
    ]
    write_text(CONFIG_DIR / "yabai" / "colors.sh", "\n".join(lines) + "\n")


def apply_borders_macos():
    # JankyBorders only reads colors at launch, so restart it via the wrapper
    script = SCRIPTS_DIR / "start-borders.sh"
    subprocess.run([str(script)], check=False)


def wal_binary():
    # pywal user installs (pip --user) are not on PATH on macOS, and the
    # python running this script may differ from the one pywal was installed with
    found = shutil.which("wal")
    if found:
        return found
    candidates = []
    site_proc = subprocess.run(
        [sys.executable, "-m", "site", "--user-base"],
        capture_output=True,
        text=True,
        check=False,
    )
    if site_proc.returncode == 0 and site_proc.stdout.strip():
        candidates.append(os.path.join(site_proc.stdout.strip(), "bin", "wal"))
    # macOS framework python user installs: ~/Library/Python/X.Y/bin
    candidates.extend(glob.glob(os.path.expanduser("~/Library/Python/*/bin/wal")))
    candidates.append(os.path.expanduser("~/.local/bin/wal"))
    candidates.append("/opt/homebrew/bin/wal")
    candidates.append("/usr/local/bin/wal")
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
    return f"#{int(r * 255):02x}{int(g * 255):02x}{int(b * 255):02x}"


def _image_mean_luminance(path):
    from PIL import Image, ImageStat  # lazy import

    img = Image.open(path).convert("L")
    img.thumbnail((256, 256), Image.BILINEAR)
    return ImageStat.Stat(img).mean[0] / 255


def _hex_luminance(hex_color):
    hex_color = hex_color.lstrip("#")
    r, g, b = (int(hex_color[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def adjust_color(hex_color, target_l, max_s=0.20):
    """Pin lightness, cap saturation so backgrounds don't get garish."""
    h, _, s = hex_to_hls(hex_color)
    s = min(s, max_s)
    return hls_to_hex(h, target_l, s)


def ensure_readability(hex_color, min_l=0.65, min_s=0.40, max_s=0.85):
    """Keep accents bright enough for dark backgrounds without oversaturating."""
    h, l, s = hex_to_hls(hex_color)
    l = max(l, min_l)
    # Near-grayscale in, grayscale out: keep B&W wallpapers from
    # turning every accent into a forced pastel.
    if s < 0.12:
        return hls_to_hex(h, l, s)
    s = max(min_s, min(s, max_s))
    return hls_to_hex(h, l, s)


def match_hue_slots(hex_colors):
    """Assign each chromatic role the unused color nearest its hue.

    Returns a dict mapping role name to index in hex_colors; the closest
    (role, color) pair wins each round so role names match actual hues.
    """
    roles = (
        ("red", 0.0),
        ("yellow", 1 / 6),
        ("green", 2 / 6),
        ("cyan", 3 / 6),
        ("blue", 4 / 6),
        ("purple", 5 / 6),
    )
    hues = [hex_to_hls(c)[0] for c in hex_colors]
    free_colors = set(range(len(hex_colors)))
    free_roles = list(roles)
    assignment = {}
    while free_roles:
        best = None
        for name, target in free_roles:
            for i in free_colors:
                dist = abs(hues[i] - target)
                dist = min(dist, 1.0 - dist)
                if best is None or dist < best[0]:
                    best = (dist, name, i)
        _, name, i = best
        assignment[name] = i
        free_colors.remove(i)
        free_roles = [r for r in free_roles if r[0] != name]
    return assignment


def generate_theme_from_wallpaper(wallpaper_path):
    """Run pywal on the wallpaper and write the curated theme.json.
    Returns True on success; on failure prints a warning and returns False
    so the caller can still set the wallpaper."""
    # Light wallpaper -> light theme (pywal defaults to dark).
    # Use _image_mean_luminance if available, else assume dark.
    try:
        is_light = _image_mean_luminance(wallpaper_path) > 0.5
    except Exception:
        is_light = False
    wal_cmd = [wal_binary(), "-i", wallpaper_path, "-n", "-s", "-q", "-e"]
    if is_light:
        wal_cmd.append("-l")
    try:
        # -e skips pywal's reload step (it needs pidof, absent on macOS);
        # we reload our own surfaces after generating the theme.
        subprocess.run(wal_cmd, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(
            "Warning: pywal failed; theme not regenerated, but wallpaper will still be set."
        )
        return False
    wal_colors_path = os.path.expanduser("~/.cache/wal/colors.json")
    try:
        with open(wal_colors_path, "r") as f:
            wal = json.load(f)
    except FileNotFoundError:
        print("Warning: pywal colors not found; theme not regenerated.")
        return False

    bg_color = wal["special"]["background"]
    bg_lum = _hex_luminance(bg_color)
    if bg_lum > 0.5:
        mantle = adjust_color(bg_color, target_l=0.88, max_s=0.10)
        base = adjust_color(bg_color, target_l=0.92, max_s=0.10)
        surface = adjust_color(bg_color, target_l=0.96, max_s=0.10)
    else:
        mantle = adjust_color(bg_color, target_l=0.09, max_s=0.10)
        base = adjust_color(bg_color, target_l=0.12, max_s=0.10)
        surface = adjust_color(bg_color, target_l=0.17, max_s=0.10)

    # Pywal's ANSI slots don't reliably hold their nominal hues, so match
    # the six chromatic colors to roles by nearest hue instead of position.
    slots = [wal["colors"][f"color{i}"] for i in range(1, 7)]
    brights = [wal["colors"][f"color{i}"] for i in range(9, 15)]
    hue_slot = match_hue_slots(slots)

    my_theme = {
        "base": base,
        "mantle": mantle,
        "surface": surface,
        "text": wal["special"]["foreground"],
        "muted": adjust_color(wal["colors"]["color8"], target_l=0.45, max_s=0.15),
        "white": wal["colors"]["color15"],
        "red": ensure_readability(slots[hue_slot["red"]]),
        "green": ensure_readability(slots[hue_slot["green"]]),
        "yellow": ensure_readability(slots[hue_slot["yellow"]]),
        "blue": ensure_readability(slots[hue_slot["blue"]]),
        "purple": ensure_readability(slots[hue_slot["purple"]]),
        "cyan": ensure_readability(slots[hue_slot["cyan"]]),
        "rose": ensure_readability(brights[hue_slot["red"]]),
        "light_green": ensure_readability(brights[hue_slot["green"]]),
        "light_peach": ensure_readability(brights[hue_slot["yellow"]]),
        "light_blue": ensure_readability(brights[hue_slot["blue"]]),
        "light_purple": ensure_readability(brights[hue_slot["purple"]]),
        "light_cyan": ensure_readability(brights[hue_slot["cyan"]]),
        "peach": wal["colors"]["color15"],
    }

    theme_out = THEME_MACOS_JSON if sys.platform == "darwin" else THEME_JSON
    with open(theme_out, "w") as f:
        json.dump(my_theme, f, indent=2)

    # Lets app backgrounds (kitty/spotify/firefox) follow the wallpaper.
    # Platform-specific file so macOS and Linux don't clobber each other.
    filename = "wallpaper-macos.txt" if sys.platform == "darwin" else "wallpaper-linux.txt"
    write_text(SCRIPTS_DIR / filename, wallpaper_path + "\n")

    print(f"Theme generated from {os.path.basename(wallpaper_path)}!")
    print(f"Base BG: {base}, Mantle: {mantle}, Surface: {surface}")
    return True


def set_wallpaper(wallpaper_path):
    """Set the platform wallpaper. Runs after theme generation so they never desync."""
    print(f"Setting wallpaper to {wallpaper_path}...")
    if sys.platform == "darwin":
        # macOS 26+: update WallpaperKit plist directly then restart the agent.
        # (Finder/System Events AppleScript and NSWorkspace are no-ops.)
        try:
            import plistlib

            plist_path = os.path.expanduser(
                "~/Library/Application Support/com.apple.wallpaper/store/Index.plist"
            )
            r = subprocess.run(
                ["plutil", "-convert", "xml1", "-o", "-", plist_path],
                capture_output=True,
                check=False,
            )
            d = plistlib.loads(r.stdout)
            cfg = plistlib.dumps(
                {"type": "imageFile", "url": {"relative": "file://" + wallpaper_path}},
                fmt=plistlib.FMT_BINARY,
            )

            def update(x):
                if isinstance(x, dict):
                    for ch in x.get("Choices", []):
                        if (
                            isinstance(ch, dict)
                            and ch.get("Provider") == "com.apple.wallpaper.choice.image"
                        ):
                            ch["Configuration"] = cfg
                    for v in x.values():
                        update(v)
                elif isinstance(x, list):
                    for v in x:
                        update(v)

            update(d)
            tmp = plist_path + ".tmp"
            with open(tmp, "wb") as f:
                f.write(plistlib.dumps(d, fmt=plistlib.FMT_BINARY))
            os.replace(tmp, plist_path)
            subprocess.run(
                ["killall", "WallpaperAgent"], capture_output=True, check=False
            )
        except (OSError, ValueError) as e:
            print(f"Warning: failed to set macOS wallpaper: {e}")
        return

def sync_macos_appearance():
    # Keep the macOS light/dark mode in sync with the wallpaper, so apps
    # that follow the system theme (including Firefox webpages) match it.
    if sys.platform != "darwin":
        return
    dark = not wallpaper_is_light()
    script = (
        'tell application "System Events" to tell appearance preferences '
        f"to set dark mode to {str(dark).lower()}"
    )
    try:
        subprocess.run(["osascript", "-e", script], check=True, capture_output=True)
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"Warning: could not sync macOS appearance: {e}")


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
        subprocess.run(["hyprctl", "reload"], capture_output=True, check=False)


def reload_quickshell():
    if _ancestor_is_quickshell():
        print("Wallpaper changed from within quickshell; reloading colors dynamically.")
        return
    if not shutil.which("quickshell"):
        return
    subprocess.run(["killall", "quickshell"], capture_output=True, check=False)
    for _ in range(50):
        if (
            subprocess.run(
                ["pgrep", "-x", "quickshell"], capture_output=True, check=False
            ).returncode
            != 0
        ):
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
        subprocess.run(["kitty", "@", "load-config"], capture_output=True, check=False)


def reload_dunst():
    # dunst has no reload; restart it to pick up the rewritten dunstrc.
    if (
        shutil.which("dunst")
        and shutil.which("pgrep")
        and subprocess.run(
            ["pgrep", "-x", "dunst"], capture_output=True, check=False
        ).returncode
        == 0
    ):
        subprocess.run(["killall", "dunst"], capture_output=True, check=False)
        subprocess.Popen(
            ["dunst"],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def reload_spicetify():
    # Applies color.ini; apply restarts a running Spotify, refresh patches
    # the files without launching it. Failures are printed, not swallowed.
    if not shutil.which("spicetify"):
        return
    running = subprocess.run(["pgrep", "-x", "Spotify"], capture_output=True, check=False).returncode == 0
    cmd = ["spicetify", "apply"] if running else ["spicetify", "refresh"]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip()
        print(f"spicetify {cmd[1]} failed: {detail}", file=sys.stderr)


def sync_linux_appearance():
    # Keep the Linux light/dark mode in sync with the wallpaper, so apps
    # that follow the system theme (including Firefox webpages) match it.
    if sys.platform == "darwin":
        return
    if not shutil.which("gsettings"):
        return
    scheme = "prefer-light" if wallpaper_is_light() else "prefer-dark"
    try:
        subprocess.run(
            ["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", scheme],
            check=True, capture_output=True,
        )
        print(f"Linux appearance synced to {scheme}")
    except subprocess.CalledProcessError as e:
        print(f"Warning: could not sync Linux appearance: {e}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate and apply the wallpaper-derived theme"
    )
    parser.add_argument(
        "wallpaper", nargs="?", help="Wallpaper image to theme from and set"
    )
    args = parser.parse_args()

    if args.wallpaper:
        wallpaper_path = os.path.realpath(args.wallpaper)
        if not os.path.isfile(wallpaper_path):
            print(f"Error: File {wallpaper_path} not found.")
            sys.exit(1)
        # Theme is best-effort; the wallpaper change is the primary intent
        generate_theme_from_wallpaper(wallpaper_path)

    colors = load_theme()
    if sys.platform == "darwin":
        generate_sketchybar(colors)
        generate_yabai(colors)
        generate_kitty(colors)
        generate_starship(colors)
        generate_nvim(colors)
        generate_spicetify(colors)
        generate_firefox(colors)
        sync_macos_appearance()
        apply_borders_macos()
        generate_spicetify(colors)
        # Sync macOS light/dark mode to the wallpaper.
        # Must run as the console user (not root) for System Events.
        try:
            from paths import THEME_MACOS_JSON as _TJ
            import json as _json
            _t = _json.load(open(_TJ))
            _light = _hex_luminance(_t.get("base", "#000000")) > 0.5
            _mode = "false" if _light else "true"
            _cmd = ["osascript", "-e",
                    f'tell app "System Events" to tell appearance preferences to set dark mode to {_mode}']
            if os.geteuid() == 0:
                _cu = subprocess.run(
                    ["stat", "-f", "%Su", "/dev/console"],
                    capture_output=True, text=True, check=False).stdout.strip()
                if _cu and _cu != "root":
                    _cmd = ["sudo", "-u", _cu] + _cmd
            subprocess.run(_cmd, capture_output=True, check=False)
        except Exception as e:
            print(f"Warning: could not sync macOS appearance: {e}")
        if args.wallpaper:
            set_wallpaper(wallpaper_path)
        if shutil.which("sketchybar"):
            # sketchybar is per-user; a root reload misses the user's
            # colors.sh and falls back to the seed-default colors.
            reload_cmd = ["sketchybar", "--reload"]
            if os.geteuid() == 0:
                console_user = subprocess.run(
                    ["stat", "-f", "%Su", "/dev/console"],
                    capture_output=True, text=True, check=False,
                ).stdout.strip()
                if console_user and console_user != "root":
                    reload_cmd = ["sudo", "-u", console_user, *reload_cmd]
            subprocess.run(reload_cmd, check=False)
        reload_kitty()
        bg_path = _kitty_wallpaper_path()
        if bg_path.is_file() and shutil.which("kitty"):
            # load-config does not apply background_image; push the dimmed copy live.
            subprocess.run(
                ["kitty", "@", "set-background-image", str(bg_path)],
                capture_output=True,
                check=False,
            )
        reload_spicetify()
        print("Successfully generated macOS color configs!")
        return
    generate_css(colors)
    generate_kitty(colors)
    generate_hyprland(colors)
    update_dunstrc(colors)
    generate_spicetify(colors)
    generate_nvim(colors)
    generate_firefox(colors)
    sync_linux_appearance()
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
