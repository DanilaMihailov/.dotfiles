vim.api.nvim_set_hl(0, "Beacon", { bg = "white", ctermbg = 15, default = true })

local default_config = {
    speed    = 2,
    width    = 40,
    winblend = 70,
    fps      = 60,
    min_jump = 10
}

local fake_buffer = vim.api.nvim_create_buf(false, true)

local function create_window(cfg)
    local window = vim.api.nvim_open_win(fake_buffer, false, {
        relative  = "cursor",
        row       = 0,
        col       = 0,
        width     = cfg.width,
        height    = 1,
        style     = "minimal",
        focusable = false,
        noautocmd = true
    })

    vim.api.nvim_win_set_option(window, 'winblend', cfg.winblend)
    vim.api.nvim_win_set_option(window, 'winhl', "Normal:Beacon")

    return window
end

local function close_timer(timer)
    if not timer:is_closing() then
        timer:close()
    end
end

local function highlight_cursor(cfg)
    local window = create_window(cfg)
    local fade_timer = vim.loop.new_timer()
    local ms = (1 / cfg.fps) * 1000
    fade_timer:start(0, ms, vim.schedule_wrap(function()
        if not vim.api.nvim_win_is_valid(window) then
            close_timer(fade_timer)
            return;
        end

        local winblend = vim.api.nvim_win_get_option(window, "winblend")
        local width = vim.api.nvim_win_get_width(window)
        vim.api.nvim_win_set_option(window, 'winblend', winblend + cfg.speed)
        vim.api.nvim_win_set_width(window, width - cfg.speed)

        if width == 0 or winblend == 100 then
            close_timer(fade_timer)
            vim.api.nvim_win_close(window, true)
        end
    end))
end

local prev_cursor = 0
local prev_abs = 0

local function cursor_moved(cfg)
    local cur = vim.fn.winline()
    local cur_abs = vim.fn.line(".")
    local diff = math.abs(cur - prev_cursor)
    local abs_diff = math.abs(cur_abs - prev_abs)

    if diff > cfg.min_jump and abs_diff > cfg.min_jump then
        highlight_cursor(cfg)
    end

    prev_cursor = cur
    prev_abs = cur_abs
end

local function setup(config)
    local beacon_group = vim.api.nvim_create_augroup('beacon_group', { clear = true })
    vim.api.nvim_create_autocmd('WinEnter', {
        pattern = "*",
        group = beacon_group,
        desc = "Highlight cursor",
        callback = function()
            highlight_cursor(config)
        end
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
        pattern = "*",
        group = beacon_group,
        desc = "Highlight cursor moves",
        callback = function()
            cursor_moved(config)
        end
    })
end

setup(default_config)

return {
    setup = setup
}
