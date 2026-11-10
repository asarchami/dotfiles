-- Window rules.
-- See https://wiki.hypr.land/configuring/core/rules/window-rules/

hl.window_rule({
    name   = "polkit-kde",
    match  = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "audio-control",
    match  = { class = "^(org.pulseaudio.pavucontrol)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.4", "monitor_h*0.4" },
})

hl.window_rule({
    name       = "file-manager",
    match      = { class = "^(TUI-FileManager)$" },
    float      = true,
    center     = true,
    size       = { "monitor_w*0.8", "monitor_h*0.8" },
    dim_around = true,
})

hl.window_rule({
    name       = "bluetooth-control",
    match      = { class = "^(bluetui)$" },
    float      = true,
    center     = true,
    size       = { "monitor_w*0.4", "monitor_h*0.4" },
    dim_around = true,
})

hl.window_rule({
    name       = "wifi-control",
    match      = { class = "^(impala)$" },
    float      = true,
    center     = true,
    size       = { "monitor_w*0.4", "monitor_h*0.4" },
    dim_around = true,
})
