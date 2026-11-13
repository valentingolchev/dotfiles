return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  config = function()
    require 'which-key'
    -- Group registrations moved to lua/user/keymaps.lua (section "Which-key
    -- groups", registered on the LazyLoad User event for this plugin)
  end,
}
