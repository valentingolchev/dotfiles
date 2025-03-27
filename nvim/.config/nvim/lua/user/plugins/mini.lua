return {
  {
    -- https://github.com/echasnovski/mini.nvim
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      require('mini.splitjoin').setup()

      -- 'g=' - Evaluate text and replace with output
      -- 'gx' - E[x]change text regions
      -- 'gm' - [M]ultiply (duplicate) text
      -- 'gr' - [R]eplace text with register
      -- 'gs' - [S]ort text
      require('mini.operators').setup {
        exchange = {
          prefix = 'gxt',
          reindent_linewise = true,
        },
      }

      -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
      -- left = '<M-h>',
      -- right = '<M-l>',
      -- down = '<M-j>',
      -- up = '<M-k>',
      --
      -- Move current line in Normal mode
      -- line_left = '<M-h>',
      -- line_right = '<M-l>',
      -- line_down = '<M-j>',
      -- line_up = '<M-k>',
      require('mini.move').setup()

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
