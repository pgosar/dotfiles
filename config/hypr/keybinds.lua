local monitors = require("monitors")

local mainMod = "SUPER"

-- Standard dispatchers and commands
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('HYPRSHOT_DIR="$HOME/Pictures/Screenshots/" hyprshot -m region'))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(0))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen(1))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("wofi"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

-- Focus movement keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Drag/resize window via mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Mouse scroll wheel workspace switches
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Multimedia / Brightness controls (repeating & locked)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d 0.1"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.1"), { locked = true, repeating = true })

-- Playerctl controls (locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Scrolling Layout Keybinds
hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + bracketright", hl.dsp.layout("colresize +0.1"))
hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.layout("colresize 0.5"))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.layout("colresize 1.0"))

-- Graceful exit (SUPER + M) via hl.timer
hl.bind(mainMod .. " + M", function()
    hl.exec_cmd("killall -15 firefox")
    hl.exec_cmd("hyprctl dispatch closewindow all")
    hl.timer(function()
        hl.dispatch(hl.dsp.exit())
    end, { timeout = 1500, type = "oneshot" })
end)

-- Workspace page switcher & window mover native Lua logic
local function switch_workspace(i)
    local monitors_list = hl.get_monitors()
    if #monitors_list <= 1 then
        hl.dispatch(hl.dsp.focus({ workspace = i }))
        return
    end

    local active_monitor = hl.get_active_monitor()
    local active_monitor_name = active_monitor and active_monitor.name

    local is_monitor2 = false
    if active_monitor and active_monitor.description then
        local m2_desc = monitors.monitor2:gsub("^desc:", "")
        if active_monitor.description == m2_desc then
            is_monitor2 = true
        end
    end

    local target_ws = i
    if is_monitor2 then
        target_ws = i + 10
    end

    if i == 10 then
        -- Gaming workspace exception: only switch Monitor 1 to workspace 10
        hl.dispatch(hl.dsp.focus({ workspace = 10 }))
        -- Restore focus to Monitor 2 if that was the active one
        if active_monitor_name then
            hl.dispatch(hl.dsp.focus({ monitor = active_monitor_name }))
        end
        return
    end

    hl.dispatch(hl.dsp.focus({ workspace = target_ws }))
end

local function move_window_to_workspace(i)
    local monitors_list = hl.get_monitors()
    if #monitors_list <= 1 then
        hl.dispatch(hl.dsp.window.move({ workspace = i }))
        return
    end

    local active_monitor = hl.get_active_monitor()
    local is_monitor2 = false
    if active_monitor and active_monitor.description then
        local m2_desc = monitors.monitor2:gsub("^desc:", "")
        if active_monitor.description == m2_desc then
            is_monitor2 = true
        end
    end

    local target_ws = i
    if is_monitor2 then
        target_ws = i + 10
    end

    hl.dispatch(hl.dsp.window.move({ workspace = target_ws }))
end

-- Bind SUPER + [0-9] and SUPER + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, function() switch_workspace(i) end)
    hl.bind(mainMod .. " + SHIFT + " .. key, function() move_window_to_workspace(i) end)
end
