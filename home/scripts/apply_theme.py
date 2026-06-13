import json
import os
import re

CONFIG_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "config"))
THEME_JSON = os.path.join(os.path.dirname(os.path.abspath(__file__)), "theme.json")


def load_theme():
    with open(THEME_JSON, "r") as f:
        return json.load(f)


def hex_to_rgba(hex_color, alpha=1.0):
    hex_color = hex_color.lstrip("#")
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return f"rgba({r}, {g}, {b}, {alpha})"


def hex_to_rgb_hypr(hex_color):
    return f"rgb({hex_color.lstrip('#')})"


def hex_to_rgba_hypr(hex_color, alpha_hex):
    # alpha_hex like 'ee' or 'ff'
    return f"rgba({hex_color.lstrip('#')}{alpha_hex})"


def generate_css(colors):
    css_content = "/* Auto-generated colors */\n"
    for k, v in colors.items():
        css_content += f"@define-color {k} {v};\n"
        if k in ["surface", "base", "mantle"]:
            r = int(v[1:3], 16)
            g = int(v[3:5], 16)
            b = int(v[5:7], 16)
            css_content += f"@define-color {k}_alpha rgba({r}, {g}, {b}, 0.95);\n"

    # Generate CSS files
    target_dirs = ["wofi"]
    for d in target_dirs:
        os.makedirs(os.path.join(CONFIG_DIR, d), exist_ok=True)
        with open(os.path.join(CONFIG_DIR, d, "colors.css"), "w") as f:
            f.write(css_content)


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

    os.makedirs(os.path.join(CONFIG_DIR, "kitty"), exist_ok=True)
    with open(os.path.join(CONFIG_DIR, "kitty", "colors.conf"), "w") as f:
        f.write(content)


def generate_hyprland(colors):
    content = "# Auto-generated hyprland colors\n"
    for k, v in colors.items():
        # define both rgb(hex) and raw hex (without #) for rgba appending
        content += f"${k} = {hex_to_rgb_hypr(v)}\n"
        content += f"${k}Alpha = {v.lstrip('#')}\n"

    os.makedirs(os.path.join(CONFIG_DIR, "hypr"), exist_ok=True)
    with open(os.path.join(CONFIG_DIR, "hypr", "colors.conf"), "w") as f:
        f.write(content)

    # Generate colors.lua
    lua_content = "-- Auto-generated hyprland colors\nreturn {\n"
    for k, v in colors.items():
        lua_content += f'  {k} = "{v.lstrip("#")}",\n'
    lua_content += "}\n"
    with open(os.path.join(CONFIG_DIR, "hypr", "colors.lua"), "w") as f:
        f.write(lua_content)


def update_dunstrc(colors):
    dunstrc_path = os.path.join(CONFIG_DIR, "dunst", "dunstrc")
    if not os.path.exists(dunstrc_path):
        return
    with open(dunstrc_path, "r") as f:
        content = f.read()

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

    with open(dunstrc_path, "w") as f:
        f.write(content)


def generate_spicetify(colors):
    spicetify_dir = os.path.join(CONFIG_DIR, "spicetify", "Themes", "Comfy")
    os.makedirs(spicetify_dir, exist_ok=True)

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
    with open(os.path.join(spicetify_dir, "color.ini"), "w") as f:
        f.write(content)


def generate_nvim(colors):
    nvim_colors_path = os.path.join(CONFIG_DIR, "nvim", "lua", "theme_colors.lua")
    content = "-- Auto-generated nvim colors\n"
    content += "return {\n"
    for k, v in colors.items():
        content += f'  {k} = "{v}",\n'
    content += "}\n"
    os.makedirs(os.path.dirname(nvim_colors_path), exist_ok=True)
    with open(nvim_colors_path, "w") as f:
        f.write(content)


def generate_firefox(colors):
    import configparser
    import sys

    if sys.platform == "darwin":
        base_dir = os.path.expanduser("~/Library/Application Support/Firefox")
    else:
        base_dir = os.path.expanduser("~/.config/mozilla/firefox")

    profiles_ini_path = os.path.join(base_dir, "profiles.ini")
    profile_dir = ""

    if os.path.exists(profiles_ini_path):
        config = configparser.ConfigParser()
        config.read(profiles_ini_path)
        for section in config.sections():
            if config.has_option(section, "Path") and "default-release" in config.get(
                section, "Path"
            ):
                path_val = config.get(section, "Path")
                is_relative = config.get(section, "IsRelative", fallback="1")
                if is_relative == "1":
                    profile_dir = os.path.join(base_dir, path_val)
                else:
                    profile_dir = path_val
                break

    if not profile_dir:
        import glob

        profiles = glob.glob(os.path.join(base_dir, "*.default-release"))
        if profiles:
            profile_dir = profiles[0]

    if not profile_dir:
        return

    textfox_chrome_dir = os.path.join(profile_dir, "chrome")

    if not os.path.exists(textfox_chrome_dir):
        return

    config_path = os.path.join(textfox_chrome_dir, "config.css")

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

    with open(config_path, "w") as f:
        f.write(css_content)


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
        gtk_dir = os.path.expanduser(f"~/.config/{gtk_ver}")
        os.makedirs(gtk_dir, exist_ok=True)
        with open(gtk_dir + "/gtk.css", "w") as f:
            f.write(css_content)


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

    import configparser

    for qt_ver in ["qt5ct", "qt6ct"]:
        colors_dir = os.path.expanduser(f"~/.config/{qt_ver}/colors")
        os.makedirs(colors_dir, exist_ok=True)
        with open(os.path.join(colors_dir, "pywal.conf"), "w") as f:
            f.write(conf_content)

        qt_conf_path = os.path.expanduser(f"~/.config/{qt_ver}/{qt_ver}.conf")
        config = configparser.ConfigParser()
        config.optionxform = str

        if os.path.exists(qt_conf_path):
            config.read(qt_conf_path)

        if not config.has_section("Appearance"):
            config.add_section("Appearance")

        config.set(
            "Appearance",
            "color_scheme_path",
            os.path.expanduser(f"~/.config/{qt_ver}/colors/pywal.conf"),
        )
        config.set("Appearance", "custom_palette", "true")
        config.set("Appearance", "style", "Fusion")

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
    content += '        xhr.open("GET", "file:///home/chilly/code/dotfiles/home/scripts/theme.json?t=" + Date.now());\n'
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

    quickshell_dir = os.path.join(CONFIG_DIR, "quickshell")
    os.makedirs(quickshell_dir, exist_ok=True)
    with open(os.path.join(quickshell_dir, "Colors.qml"), "w") as f:
        f.write(content)


def main():
    colors = load_theme()
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
    print("Successfully generated color configs!")


if __name__ == "__main__":
    main()
