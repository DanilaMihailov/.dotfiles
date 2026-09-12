-- Hyprland configuration entry point.
-- Modules are loaded in dependency and configuration order.

local programs = require("modules.programs")

require("modules.monitors")
require("modules.autostart")
require("modules.environment")
require("modules.appearance")
require("modules.animations")
require("modules.layouts")
require("modules.misc")
require("modules.input")
require("modules.keybinds")(programs)
require("modules.windowrules")

