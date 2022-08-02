vim.cmd("hi BeaconDefault guibg=white ctermbg=15")
vim.cmd("hi! link Beacon BeaconDefault")

local function highlight_position()
    local fake_buf = vim.api.nvim_create_buf(false, true)
    local window = vim.api.nvim_open_win(fake_buf, false, {
        relative  = "cursor",
        row       = 0,
        col       = 0,
        width     = 30,
        height    = 1,
        style     = "minimal",
        focusable = false,
        noautocmd = true
    })

    vim.api.nvim_win_set_option(window, 'winblend', 70)
    vim.api.nvim_win_set_option(window, 'winhl', "Normal:Beacon")

    local fade_timer = vim.loop.new_timer()
    fade_timer:start(0, 16, vim.schedule_wrap(function()
        if not vim.api.nvim_win_is_valid(window) then
            if not fade_timer:is_closing() then
                fade_timer:close()
            end
            return;
        end
        local winblend = vim.api.nvim_win_get_option(window, "winblend")
        local width = vim.api.nvim_win_get_width(window)
        vim.api.nvim_win_set_option(window, 'winblend', winblend + 1)
        vim.api.nvim_win_set_width(window, width - 1)
        if width == 0 or winblend == 100 then
            if not fade_timer:is_closing() then
                fade_timer:close()
            end
            vim.api.nvim_win_close(window, true)
        end
    end))
end

local beacon_group = vim.api.nvim_create_augroup('beacon_group', { clear = true })
vim.api.nvim_create_autocmd('WinEnter', {
    pattern = "*",
    group = beacon_group,
    desc = "Highlight cursor",
    callback = function()
        highlight_position()
    end
})
