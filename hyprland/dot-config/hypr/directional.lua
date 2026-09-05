local M = {}

local directions = {
    left  = { x = -1, y =  0 },
    right = { x =  1, y =  0 },
    up    = { x =  0, y = -1 },
    down  = { x =  0, y =  1 },
}

-- Workspaces form a vertical axis. Horizontal navigation therefore goes from
-- a window directly to the monitor next to it. Change this table if you want
-- workspaces to be horizontal instead.
local workspace_step = {
    up   = -1,
    down = 1,
}

local function later(callback)
    hl.timer(callback, { timeout = 1, type = "oneshot" })
end

local function monitor_id(monitor)
    return monitor and monitor.id
end

local function workspace_id(workspace)
    return workspace and workspace.id
end

local function same_monitor(a, b)
    return monitor_id(a) ~= nil and monitor_id(a) == monitor_id(b)
end

local function window_position(window)
    if not window or not window.at then
        return nil, nil
    end

    return window.at.x or window.at[1], window.at.y or window.at[2]
end

local function window_state(window)
    local x, y = window_position(window)

    return {
        address = window and window.address,
        monitor = monitor_id(window and window.monitor),
        workspace = workspace_id(window and window.workspace),
        x = x,
        y = y,
    }
end

local function workspace_signature(workspace)
    if not workspace then
        return ""
    end

    local windows = {}
    for _, window in ipairs(hl.get_workspace_windows(workspace)) do
        local x, y = window_position(window)
        table.insert(windows, table.concat({
            window.address or "",
            tostring(x),
            tostring(y),
        }, ":"))
    end
    table.sort(windows)

    return table.concat(windows, "|")
end

local function window_was_moved(before, window, before_layout, workspace)
    local after = window_state(window)

    return before.address ~= after.address
        or before.monitor ~= after.monitor
        or before.workspace ~= after.workspace
        or before.x ~= after.x
        or before.y ~= after.y
        or before_layout ~= workspace_signature(workspace)
end

local function next_workspace(monitor, current, direction)
    local step = workspace_step[direction]
    if not step or not monitor or not current then
        return nil
    end

    local candidates = {}
    for _, workspace in ipairs(hl.get_workspaces()) do
        if not workspace.special and same_monitor(workspace.monitor, monitor) then
            table.insert(candidates, workspace)
        end
    end

    table.sort(candidates, function(a, b)
        return a.id < b.id
    end)

    for index, workspace in ipairs(candidates) do
        if workspace.id == current.id then
            return candidates[index + step]
        end
    end

    return nil
end

local function monitor_rect(monitor)
    local scale = monitor.scale or 1
    local x = monitor.x or (monitor.position and monitor.position.x) or 0
    local y = monitor.y or (monitor.position and monitor.position.y) or 0
    local width = (monitor.width or 0) / scale
    local height = (monitor.height or 0) / scale

    return {
        left = x,
        right = x + width,
        top = y,
        bottom = y + height,
        center_x = x + width / 2,
        center_y = y + height / 2,
    }
end

local function interval_distance(a1, a2, b1, b2)
    if a2 < b1 then
        return b1 - a2
    elseif b2 < a1 then
        return a1 - b2
    end

    return 0
end

local function monitor_score(current, candidate, direction)
    local vector = directions[direction]
    local a = monitor_rect(current)
    local b = monitor_rect(candidate)
    local dx = b.center_x - a.center_x
    local dy = b.center_y - a.center_y
    local forward = dx * vector.x + dy * vector.y

    if forward <= 0 then
        return nil
    end

    local sideways
    if vector.x ~= 0 then
        sideways = interval_distance(a.top, a.bottom, b.top, b.bottom)
    else
        sideways = interval_distance(a.left, a.right, b.left, b.right)
    end

    -- Prefer a monitor that overlaps on the perpendicular axis. Distance then
    -- breaks ties, so staggered and differently-sized arrangements still work.
    local overlap_penalty = sideways == 0 and 0 or 1000000
    return overlap_penalty + forward * forward + sideways * sideways
end

local function next_monitor(current, direction)
    if not current then
        return nil
    end

    local best, best_score
    for _, monitor in ipairs(hl.get_monitors()) do
        if not same_monitor(monitor, current) then
            local score = monitor_score(current, monitor, direction)
            if score and (not best_score or score < best_score) then
                best = monitor
                best_score = score
            end
        end
    end

    return best
end

local function focus_fallback(direction, monitor, workspace)
    local target_workspace = next_workspace(monitor, workspace, direction)
    if target_workspace then
        hl.dispatch(hl.dsp.focus({ workspace = target_workspace }))
        return
    end

    local target_monitor = next_monitor(monitor, direction)
    if target_monitor then
        hl.dispatch(hl.dsp.focus({ monitor = target_monitor }))
    end
end

function M.focus(direction)
    assert(directions[direction], "unknown direction: " .. tostring(direction))

    return function()
        local before = hl.get_active_window()
        local address = before and before.address
        local monitor = hl.get_active_monitor()
        local workspace = hl.get_active_workspace()

        hl.dispatch(hl.dsp.focus({ direction = direction }))

        later(function()
            local after = hl.get_active_window()
            if address == (after and after.address) then
                focus_fallback(direction, monitor, workspace)
            end
        end)
    end
end

function M.move(direction)
    assert(directions[direction], "unknown direction: " .. tostring(direction))

    return function()
        local window = hl.get_active_window()
        if not window then
            return
        end

        local before = window_state(window)
        local monitor = window.monitor or hl.get_active_monitor()
        local workspace = window.workspace or hl.get_active_workspace()
        local before_layout = workspace_signature(workspace)

        hl.dispatch(hl.dsp.window.move({ direction = direction }))

        later(function()
            local current = hl.get_window("address:" .. before.address)
            if not current or window_was_moved(before, current, before_layout, workspace) then
                return
            end

            local target_workspace = next_workspace(monitor, workspace, direction)
            if target_workspace then
                hl.dispatch(hl.dsp.window.move({
                    workspace = target_workspace,
                    follow = true,
                }))
                return
            end

            local target_monitor = next_monitor(monitor, direction)
            if target_monitor then
                hl.dispatch(hl.dsp.window.move({
                    monitor = target_monitor,
                    follow = true,
                }))
            end
        end)
    end
end

return M
