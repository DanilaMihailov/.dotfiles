-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

-- Fast, low-travel animations for a responsive feel.
hl.animation({ leaf = "global",        enabled = true, speed = 1.0, bezier = "quick" })
hl.animation({ leaf = "border",        enabled = true, speed = 0.7, bezier = "quick" })
hl.animation({ leaf = "windows",       enabled = true, speed = 1.0, bezier = "quick" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 1.0, bezier = "quick", style = "popin 95%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 0.8, bezier = "quick", style = "popin 95%" })
hl.animation({ leaf = "fade",          enabled = true, speed = 0.8, bezier = "quick" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 0.8, bezier = "quick" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 0.7, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 1.0, bezier = "quick" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 1.0, bezier = "quick", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 0.8, bezier = "quick", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 0.8, bezier = "quick" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.7, bezier = "quick" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.2, bezier = "quick", style = "slidevert" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.2, bezier = "quick", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.2, bezier = "quick", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1.0, bezier = "quick", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 1.0, bezier = "quick" })

-- Launchers are opened constantly and should appear immediately.
hl.layer_rule({ match = { namespace = "^launcher$" }, no_anim = true })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

