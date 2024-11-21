-- copilot
-- https://github.com/github/copilot.vim

return {
  'github/copilot.vim',
  config = function()
    -- keymaps
    local keymap = vim.keymap
    keymap.set('i', '<C-Y>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })

    vim.g.copilot_no_tab_map = true
  end,
}
