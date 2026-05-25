local monitors = require("monitors")

-- -----------------
-- WORKSPACE RULES
-- -----------------

-- Monitor 1 workspaces (1-10)
for i = 1, 10 do
    local rule = {
        workspace = tostring(i),
        monitor = monitors.monitor1,
        persistent = true
    }
    if i == 1 then
        rule.default = true
    elseif i == 10 then
        rule.layout = "scrolling"
    end
    hl.workspace_rule(rule)
end

-- Monitor 2 workspaces (11-20)
for i = 11, 20 do
    local rule = {
        workspace = tostring(i),
        monitor = monitors.monitor2,
        persistent = true
    }
    if i == 11 then
        rule.default = true
    end
    hl.workspace_rule(rule)
end

-- -----------------
-- WINDOW RULES
-- -----------------

hl.window_rule({
    name = "steam-launcher",
    match = { class = "^([Ss]team)$" },
    monitor = monitors.monitor1,
    workspace = 10,
})

hl.window_rule({
    name = "steam-monitor",
    match = { class = "^(steam_app_.*)$" },
    monitor = monitors.monitor1,
    workspace = 10,
})

hl.window_rule({
    name = "wofi-theme-fixes",
    match = { class = "^(wofi)$" },
    rounding = 16,
    border_size = 0,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})
