local link_opener = require("org-roam.link_opener")

describe("link_opener", function()
    before_each(function()
        -- Set up a mock environment for each test
        vim.cmd("new")
        vim.bo.filetype = "org"
    end)

    after_each(function()
        -- Clean up after each test
        vim.cmd("bdelete!")
    end)

    it("should open file links", function()
        local test_file = "test_file.org"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "[[file:" .. test_file .. "][Test File]]" })
        vim.api.nvim_win_set_cursor(0, { 1, 3 }) -- Place cursor on the link

        local old_cmd = vim.cmd
        vim.cmd = function(command)
            assert.are.equal("edit " .. vim.fn.fnameescape(test_file), command)
        end

        link_opener.open_org_link()

        vim.cmd = old_cmd
    end)

    it("should open id links", function()
        local test_id = "20220101T120000"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "[[id:" .. test_id .. "][Test Node]]" })
        vim.api.nvim_win_set_cursor(0, { 1, 3 }) -- Place cursor on the link

        local old_node_open = require("org-roam.api").node.open
        require("org-roam.api").node.open = function(id)
            assert.are.equal(test_id, id)
        end

        link_opener.open_org_link()

        require("org-roam.api").node.open = old_node_open
    end)

    it("should notify on unsupported link types", function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "[[unsupported:link][Unsupported Link]]" })
        vim.api.nvim_win_set_cursor(0, { 1, 3 }) -- Place cursor on the link

        local old_notify = vim.notify
        vim.notify = function(msg, level)
            assert.are.equal("Unsupported link type: unsupported", msg)
            assert.are.equal(vim.log.levels.WARN, level)
        end

        link_opener.open_org_link()

        vim.notify = old_notify
    end)
end)
