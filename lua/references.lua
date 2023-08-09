local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

M = {}

M.picker = function(opts, prompt, title, author)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = prompt,
        finder = finders.new_table {
            results = vim.fn['references#bibTexSource']()
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.fn['InsertReferenceAtCursor'](selection[1], title,author)
            end)
            return true
        end,
    }):find()
end

return M
