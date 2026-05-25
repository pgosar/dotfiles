-- ----------------------------------------------------
-- Hyprland Lua Configuration Entrypoint (v0.55.2)
-- ----------------------------------------------------

-- ---------------------
-- ENVIRONMENT VARIABLES
-- ---------------------
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- ---------------------
-- AUTOSTART
-- ---------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload -n")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/waybar/scripts/launch.sh")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-gammarelay-rs")
end)

-- ---------------------
-- INPUT & GESTURES
-- ---------------------
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- ---------------------
-- WORKSPACE SYNC EVENT
-- ---------------------
hl.on("workspace.active", function(workspace)
    local monitors_list = hl.get_monitors()
    if #monitors_list <= 1 then return end
    if _G.syncing_workspaces then return end

    local id = workspace.id
    if id == 10 or id == 20 then return end -- Gaming workspace exception

    if id >= 1 and id <= 9 then
        local target_ws = id + 10
        _G.syncing_workspaces = true
        hl.dispatch(hl.dsp.focus({ workspace = target_ws }))
        hl.dispatch(hl.dsp.focus({ workspace = id }))
        _G.syncing_workspaces = nil
    elseif id >= 11 and id <= 19 then
        local target_ws = id - 10
        _G.syncing_workspaces = true
        hl.dispatch(hl.dsp.focus({ workspace = target_ws }))
        hl.dispatch(hl.dsp.focus({ workspace = id }))
        _G.syncing_workspaces = nil
    end
end)

-- ---------------------
-- LOAD MODULES
-- ---------------------
require("monitors")
require("theme")
require("rules")
require("keybinds")
