-- Environment variables.
-- See https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Hyprcursor settings.
hl.env("HYPRCURSOR_THEME", "THEME_NAME")
hl.env("HYPRCURSOR_SIZE", "24")

-- XWayland cursor settings, used by applications such as VS Code.
hl.env("XCURSOR_THEME", "THEME_NAME")
hl.env("XCURSOR_SIZE", "24")
