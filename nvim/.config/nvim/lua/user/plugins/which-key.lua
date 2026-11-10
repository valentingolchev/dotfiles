return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  config = function()
    local wk = require 'which-key'

    -- Document existing key chains
    wk.add {
      { '<leader>c', desc = '[C]ode' },
      { '<leader>d', desc = '[D]ocument' },
      { '<leader>g', desc = '[G]it' },
      { '<leader>h', desc = 'Git [H]unk' },
      { '<leader>r', desc = '[R]ename' },
      { '<leader>s', desc = '[S]earch' },
      { '<leader>w', desc = '[W]orkspace' },
      { '<leader>t', desc = '[T]oggle' },
      {
        mode = { 'v' },
        { '<leader>h', desc = 'Git [H]unk' },
      },
    }

    -- visual mode
    wk.add({}, { mode = 'v' })
  end,
}
