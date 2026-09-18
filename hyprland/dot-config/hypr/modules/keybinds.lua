return function(programs)
    local terminal = programs.terminal
    local menu = programs.menu

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(
  mainMod .. " + E",
  hl.dsp.exec_cmd(
    "pkill -x rofi || rofi -show filebrowser -show-icons " ..
    "-theme /home/zen/.config/rofi/filebrowser.rasi"
  )
)
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill -x rofi || rofi -show drun"))
hl.bind(
  mainMod .. " + W",
  hl.dsp.exec_cmd("pkill -x rofi || /home/zen/.local/bin/rofi-workspace-switcher")
)
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("/home/zen/.local/bin/rofi-workspace-rename"))
hl.bind("CTRL + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(
  mainMod .. " + CTRL + SPACE",
  hl.dsp.exec_cmd(
    "pkill -x rofi || /home/zen/.local/bin/emoji-picker"
  )
)
hl.bind(mainMod .. " + GRAVE", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(
  mainMod .. " + ESCAPE",
  hl.dsp.exec_cmd("swaync-client -t -sw"),
  { device = { inclusive = true, list = { "by-tech-air60-2", "by-tech-air60-1", "by-tech-air60" } } }
)
hl.bind("Print", hl.dsp.exec_cmd("flock --close --nonblock /tmp/hyprshot-region.lock hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))

local function mac_clipboard_shortcut(key)
    return function()
        local window = hl.get_active_window()
        local class = window and string.lower(window.class or "") or ""
        local mods = "CTRL"

        if class == "foot" or class == "footclient" then
            -- Terminals reserve Ctrl+C for SIGINT and use Ctrl+Shift+C/V.
            mods = "CTRL + SHIFT"
        end

        hl.dispatch(hl.dsp.send_shortcut({
            mods = mods,
            key = key,
            window = window,
        }))
    end
end

hl.bind(mainMod .. " + C", mac_clipboard_shortcut("C"))
hl.bind(mainMod .. " + V", mac_clipboard_shortcut("V"))

local function focus_or_workspace(direction, workspace)
    return function()
        local before = hl.get_active_window()
        local before_address = before and before.address

        hl.dispatch(hl.dsp.focus({ direction = direction }))

        local after = hl.get_active_window()
        local after_address = after and after.address
        if before_address == after_address then
            hl.dispatch(hl.dsp.focus({ workspace = workspace }))
        end
    end
end

local function focus_or_monitor(window_direction, horizontal_step)
    return function()
        local before = hl.get_active_window()
        local before_address = before and before.address

        hl.dispatch(hl.dsp.focus({ direction = window_direction }))

        hl.timer(function()
            local after = hl.get_active_window()
            local after_address = after and after.address
            if before_address == after_address then
                local current = hl.get_active_monitor()
                local target = nil
                local target_distance = math.huge

                for _, monitor in pairs(hl.get_monitors()) do
                    local distance = (monitor.position.x - current.position.x) * horizontal_step
                    if distance > 0 and distance < target_distance then
                        target = monitor
                        target_distance = distance
                    end
                end

                if target then
                    hl.dispatch(hl.dsp.focus({ monitor = target }))
                end
            end
        end, { timeout = 1, type = "oneshot" })
    end
end

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h", focus_or_monitor("left", -1))
hl.bind(mainMod .. " + l", focus_or_monitor("right", 1))
hl.bind(mainMod .. " + k", focus_or_workspace("up", "m-1"))
hl.bind(mainMod .. " + j", focus_or_workspace("down", "m+1"))
hl.bind(mainMod .. " + CTRL + h", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.focus({ monitor = "r" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.focus({ monitor = "u" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.focus({ monitor = "d" }))
hl.bind(mainMod .. " + CTRL + SHIFT + h", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + SHIFT + l", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ workspace = "m+1" }))

hl.bind(mainMod .. " + SHIFT + p", hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + SHIFT + n", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + p", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + n", hl.dsp.focus({ workspace = "m+1" }))

-- Scrolling layout: combine/expel windows
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.layout("consume_or_expel next"))

-- Move the current scrolling-layout column without combining windows
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.layout("swapcol r"))

hl.bind(mainMod .. " + PERIOD", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + COMMA", hl.dsp.layout("colresize -conf"))

local function rofiIsOpen()
    for _, layer in ipairs(hl.get_layers()) do
        if layer.namespace == "rofi" then return true end
    end
    return false
end

local modTabGeneration = 0

local function modTabModifierIsDown()
    -- The internal keyboard swaps Alt and Super, while external keyboards do
    -- not. Check both pairs of physical XKB keycodes after the logical
    -- SUPER+Tab chord has already started.
    return hl.is_key_down(133) or hl.is_key_down(134)
        or hl.is_key_down(64) or hl.is_key_down(108)
end

-- Hyprland 0.56 does not dispatch release binds reliably here, so detect Tab-up
-- through its key-state API. A quick gesture focuses the previous window; if
-- Super remains held for 120 ms after Tab-up, open the full Rofi switcher.
hl.bind(mainMod .. " + Tab", function()
    if rofiIsOpen() then return end

    modTabGeneration = modTabGeneration + 1
    local generation = modTabGeneration
    local tabReleasePoll

    tabReleasePoll = hl.timer(function()
        if generation ~= modTabGeneration then
            tabReleasePoll:set_enabled(false)
            return
        end
        if hl.is_key_down("Tab") then return end

        tabReleasePoll:set_enabled(false)
        local heldTicks = 0
        local superReleasePoll
        superReleasePoll = hl.timer(function()
            if generation ~= modTabGeneration then
                superReleasePoll:set_enabled(false)
                return
            end

            if not modTabModifierIsDown() then
                superReleasePoll:set_enabled(false)
                hl.dispatch(hl.dsp.focus({ last = true }))
                return
            end

            heldTicks = heldTicks + 1
            if heldTicks < 24 then return end

            superReleasePoll:set_enabled(false)
            hl.dispatch(hl.dsp.exec_cmd("/home/zen/.local/bin/rofi-window-switcher"))
        end, { timeout = 5, type = "repeat" })
    end, { timeout = 5, type = "repeat" })
end, { non_consuming = true })

hl.bind(
    mainMod .. " + SHIFT + F",
    hl.dsp.layout("fit active")
)

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Follow the same window/monitor navigation as mainMod + h/l. Add Shift to
-- scroll through workspaces on the active monitor.
hl.bind(mainMod .. " + mouse_down", focus_or_monitor("right", 1))
hl.bind(mainMod .. " + mouse_up",   focus_or_monitor("left", -1))
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume +5 --max-volume 100"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume -5 --max-volume 100"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("swayosd-client --brightness +5 --device amdgpu_bl1"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("swayosd-client --brightness -5 --device amdgpu_bl1"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -d 'tpacpi::kbd_backlight' set +1"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown",hl.dsp.exec_cmd("brightnessctl -d 'tpacpi::kbd_backlight' set 1-"),  { locked = true, repeating = true })

-- ThinkPad function-row actions. A udev hwdb override remaps F8 from the
-- system WLAN key to KEY_PROG1, exposed by XKB as XF86Launch1.
-- Override: /etc/udev/hwdb.d/90-thinkpad-function-keys.hwdb
hl.bind(
    "XF86Display",
    hl.dsp.exec_cmd("/home/zen/.config/waybar/internal-display-toggle.sh toggle")
)
hl.bind(
    "XF86Launch1",
    hl.dsp.exec_cmd("/home/zen/.config/waybar/throne-toggle.sh toggle")
)
hl.bind(
    "XF86NotificationCenter",
    hl.dsp.exec_cmd("/home/zen/.local/bin/focus-or-launch-app mattermost mattermost-desktop")
)
hl.bind(
    "XF86PickupPhone",
    hl.dsp.exec_cmd(
        "/home/zen/.local/bin/focus-or-launch-app " ..
        "'telemost|телемост|imnopdcfcjmmfankbhhfchjfcgjobibi' " ..
        "chrome-imnopdcfcjmmfankbhhfchjfcgjobibi-Default"
    )
)
hl.bind("XF86HangupPhone", hl.dsp.exec_cmd("swaync-client -d -sw"))
hl.bind("XF86Favorites", hl.dsp.exec_cmd("foot --title=Codex zsh -lic 'exec codex'"))

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


end
