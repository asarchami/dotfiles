-- Hyprfloat keybinds and window rules.
-- See https://github.com/yz778/hyprfloat

-- ALT-Tab window switcher.
hl.bind("ALT + TAB", hl.dsp.exec_cmd("hyprfloat alttab next"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.exec_cmd("hyprfloat alttab prev"))
hl.bind("ALT + GRAVE", hl.dsp.exec_cmd("hyprfloat alttab next sameclass"))
hl.bind("ALT + SHIFT + GRAVE", hl.dsp.exec_cmd("hyprfloat alttab prev sameclass"))

-- Rules for the hyprfloat windows.
hl.window_rule({
    match = { title = "^(hyprfloat:.*)$" },
    float = true,
})

hl.window_rule({
    match = { title = "^(hyprfloat:.*)$" },
    no_anim = true,
})

hl.window_rule({
    match = { title = "^(hyprfloat:alttab)$" },
    pin = true,
})

hl.window_rule({
    match = { title = "^(hyprfloat:alttab)$" },
    size = { 0, 0 },
})

hl.window_rule({
    match = { title = "^(hyprfloat:alttab)$" },
    stay_focused = true,
})

hl.window_rule({
    match = { title = "^(hyprfloat:dummy)$" },
    border_size = 0,
})

hl.window_rule({
    match = { title = "^(hyprfloat:dummy)$" },
    size = { 0, 0 },
})

-- Floating windows get a green to cyan border.
hl.window_rule({
    match = { float = true },
    border_color = { colors = { "rgba(00ff99ee)", "rgba(33ccffee)" }, angle = 45 },
})

-- Tiling windows get a cyan to green border.
hl.window_rule({
    match = { float = false },
    border_color = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
})

-- Overview windows get a gold to orange border.
hl.window_rule({
    match = { tag = "overview" },
    border_color = { colors = { "rgba(ffd700ee)", "rgba(ff8c00ee)" }, angle = 45 },
})

-- Main controls.
hl.bind("SUPER + BACKSLASH", hl.dsp.exec_cmd("hyprfloat overview"))
hl.bind("SUPER + SHIFT + BACKSLASH", hl.dsp.exec_cmd("hyprfloat togglefloat"))

-- Directional focus and snapping.
hl.bind("SUPER + UP", hl.dsp.exec_cmd("hyprfloat dynamicbind SUPER_UP"))
hl.bind("SUPER + DOWN", hl.dsp.exec_cmd("hyprfloat dynamicbind SUPER_DOWN"))
hl.bind("SUPER + LEFT", hl.dsp.exec_cmd("hyprfloat dynamicbind SUPER_LEFT"))
hl.bind("SUPER + RIGHT", hl.dsp.exec_cmd("hyprfloat dynamicbind SUPER_RIGHT"))

-- Snapping to screen fractions.
hl.bind("SUPER + INSERT", hl.dsp.exec_cmd("hyprfloat snap 0.0 0.0 0.0 0.5"))
hl.bind("SUPER + HOME", hl.dsp.exec_cmd("hyprfloat snap 0.0 1.0 0.0 0.5"))
hl.bind("SUPER + PAGE_UP", hl.dsp.exec_cmd("hyprfloat snap 0.7 1.0 0.0 0.5"))
hl.bind("SUPER + DELETE", hl.dsp.exec_cmd("hyprfloat snap 0.0 0.3 0.5 1.0"))
hl.bind("SUPER + END", hl.dsp.exec_cmd("hyprfloat snap 0.0 1.0 0.5 1.0"))
hl.bind("SUPER + PAGE_DOWN", hl.dsp.exec_cmd("hyprfloat snap 0.7 1.0 0.5 1.0"))

hl.bind("SUPER + SHIFT + INSERT", hl.dsp.exec_cmd("hyprfloat snap 0.0 0.7 0.0 1.0"))
hl.bind("SUPER + SHIFT + HOME", hl.dsp.exec_cmd("hyprfloat snap 0.2 0.8 0.0 1.0"))
hl.bind("SUPER + SHIFT + PAGE_UP", hl.dsp.exec_cmd("hyprfloat snap 0.7 1.0 0.0 1.0"))
hl.bind("SUPER + SHIFT + UP", hl.dsp.exec_cmd("hyprfloat snap 0.0 1.0 0.0 1.0"))

-- Multi-monitor controls.
hl.bind("SUPER + SHIFT + LEFT", hl.dsp.exec_cmd("hyprfloat movemon -1"))
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.exec_cmd("hyprfloat movemon +1"))
hl.bind("SUPER + SHIFT + DOWN", hl.dsp.exec_cmd("hyprfloat center 1.00"))

-- Workspace groups.
hl.bind("SUPER + CTRL + LEFT", hl.dsp.exec_cmd("hyprfloat workspacegroup prev"))
hl.bind("SUPER + CTRL + RIGHT", hl.dsp.exec_cmd("hyprfloat workspacegroup next"))
hl.bind("SUPER + CTRL + INSERT", hl.dsp.exec_cmd("hyprfloat workspacegroup group 1"))
hl.bind("SUPER + CTRL + HOME", hl.dsp.exec_cmd("hyprfloat workspacegroup group 2"))
hl.bind("SUPER + CTRL + PAGE_UP", hl.dsp.exec_cmd("hyprfloat workspacegroup group 3"))
hl.bind("SUPER + CTRL + M", hl.dsp.exec_cmd("hyprfloat workspacegroup move"))
