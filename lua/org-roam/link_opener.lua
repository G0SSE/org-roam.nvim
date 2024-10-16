local M = {}

function M.open_org_link()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    -- Match [[file:path/to/file.org][Description]] or [[id:20220101T120000][Description]]
    local link_pattern = "%[%[([^%[%]]+)%]%[.-%]%]"

    local start, finish, link = line:find(link_pattern, 1)
    if start and finish and col >= start and col <= finish then
        local link_type, link_target = link:match("^(%w+):(.+)$")

        if link_type == "file" then
            vim.cmd("edit " .. vim.fn.fnameescape(link_target))
        elseif link_type == "id" then
            -- Use the existing API to open nodes by ID
            require("org-roam.api").node.open(link_target)
        else
            vim.notify("Unsupported link type: " .. link_type, vim.log.levels.WARN)
        end
    end
end

function M.setup(roam)
    if roam.config.link_opener and roam.config.link_opener.enabled then
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "org",
            callback = function()
                vim.api.nvim_buf_set_keymap(
                    0,
                    "n",
                    "<CR>",
                    ':lua require("org-roam.link_opener").open_org_link()<CR>',
                    { noremap = true, silent = true }
                )
            end,
        })
    end
end

return M
