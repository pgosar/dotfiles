from pathlib import Path

DOTFILES_DIR = Path(__file__).resolve().parents[2]
HOME_DIR = DOTFILES_DIR / "home"
CONFIG_DIR = HOME_DIR / "config"
SCRIPTS_DIR = HOME_DIR / "scripts"
WALLPAPERS_DIR = HOME_DIR / "walls"

THEME_JSON = SCRIPTS_DIR / "theme.json"

HYPR_DIR = CONFIG_DIR / "hypr"
HYPRPAPER_CONFIG = HYPR_DIR / "hyprpaper.conf"
HYPRLOCK_CONFIG = HYPR_DIR / "hyprlock.conf"

QUICKSHELL_DIR = CONFIG_DIR / "quickshell"
QUICKSHELL_COLORS = QUICKSHELL_DIR / "Colors.qml"
QUICKSHELL_PATHS = QUICKSHELL_DIR / "Paths.qml"

SET_WALLPAPER_SCRIPT = SCRIPTS_DIR / "set_wallpaper.sh"
APPLY_THEME_SCRIPT = SCRIPTS_DIR / "apply_theme.py"


def file_uri(path: Path) -> str:
    return path.resolve().as_uri()
