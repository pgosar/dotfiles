import json
import os
import re

CONFIG_DIR = os.path.expanduser("~/code/dotfiles/config")
THEME_JSON = os.path.join(CONFIG_DIR, "theme.json")

def load_theme():
    with open(THEME_JSON, "r") as f:
        return json.load(f)

def hex_to_rgba(hex_color, alpha=1.0):
    hex_color = hex_color.lstrip('#')
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
        # Create an RGB-only variable for tools like Wofi that need `rgba(@color_rgb, 0.95)`
        r, g, b = int(v[1:3], 16), int(v[3:5], 16), int(v[5:7], 16)
        css_content += f"@define-color {k}_rgb {r}, {g}, {b};\n"
    
    # Generate CSS files
    target_dirs = ["waybar", "wofi"]
    for d in target_dirs:
        os.makedirs(os.path.join(CONFIG_DIR, d), exist_ok=True)
        with open(os.path.join(CONFIG_DIR, d, "colors.css"), "w") as f:
            f.write(css_content)

    # Wofi explicitly breaks when trying to apply CSS Alpha via variables, so we inject the exact rgba string directly into style.css
    wofi_style_path = os.path.join(CONFIG_DIR, "wofi", "style.css")
    if os.path.exists(wofi_style_path):
        with open(wofi_style_path, 'r') as f:
            wofi_css = f.read()
        
        # Wofi fundamentally breaks on both rgba() CSS variables and alpha(), stripping background outright. 
        # We inject the exact rgba string natively out of python over the background property instead.
        wr, wg, wb = int(colors["surface"][1:3], 16), int(colors["surface"][3:5], 16), int(colors["surface"][5:7], 16)
        wofi_css = re.sub(r'(window\s*{[^}]*background-color:\s*)[^;]+;', f'\\g<1>rgba({wr}, {wg}, {wb}, 0.95);', wofi_css)
        
        with open(wofi_style_path, 'w') as f:
            f.write(wofi_css)



def generate_kitty(colors):
    # Mapping our theme directly to kitty color numbers
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
        "color15": colors["white"]
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

def update_dunstrc(colors):
    dunstrc_path = os.path.join(CONFIG_DIR, "dunst", "dunstrc")
    if not os.path.exists(dunstrc_path): return
    with open(dunstrc_path, 'r') as f: content = f.read()

    # Use regex to find and replace color values in dunstrc safely
    content = re.sub(r'frame_color = ".*?"(?=\nseparator_color)', f'frame_color = "{colors["muted"]}"', content)

    content = re.sub(r'(\[urgency_low\][^\[]*?background = )".*?"', f'\\g<1>"{colors["surface"]}"', content)
    content = re.sub(r'(\[urgency_low\][^\[]*?foreground = )".*?"', f'\\g<1>"{colors["text"]}"', content)
    content = re.sub(r'(\[urgency_low\][^\[]*?frame_color = )".*?"', f'\\g<1>"{colors["blue"]}"', content)

    content = re.sub(r'(\[urgency_normal\][^\[]*?background = )".*?"', f'\\g<1>"{colors["surface"]}"', content)
    content = re.sub(r'(\[urgency_normal\][^\[]*?foreground = )".*?"', f'\\g<1>"{colors["text"]}"', content)
    content = re.sub(r'(\[urgency_normal\][^\[]*?frame_color = )".*?"', f'\\g<1>"{colors["purple"]}"', content)

    content = re.sub(r'(\[urgency_critical\][^\[]*?background = )".*?"', f'\\g<1>"{colors["surface"]}"', content)
    content = re.sub(r'(\[urgency_critical\][^\[]*?foreground = )".*?"', f'\\g<1>"{colors["text"]}"', content)
    content = re.sub(r'(\[urgency_critical\][^\[]*?frame_color = )".*?"', f'\\g<1>"{colors["red"]}"', content)

    with open(dunstrc_path, 'w') as f: f.write(content)

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

def main():
    colors = load_theme()
    generate_css(colors)
    generate_kitty(colors)
    generate_hyprland(colors)
    update_dunstrc(colors)
    generate_nvim(colors)
    print("Successfully generated color configs!")

if __name__ == "__main__":
    main()
