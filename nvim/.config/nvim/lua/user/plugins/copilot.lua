return {
  {
    -- https://github.com/zbirenbaum/copilot.lua
    'zbirenbaum/copilot.lua',
    lazy = true,
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        opts = {
          copilot_model = 'gpt-4o-copilot',
          suggestion = { enabled = true },
          panel = { enabled = false },
          filetypes = { ['*'] = true },
        },
      }

      -- keymaps
      local keymap = vim.keymap
      local suggestion = require 'copilot.suggestion'

      keymap.set('n', '<leader>ctt', suggestion.toggle_auto_trigger, {
        desc = '[C]opilot [T]oggle auto [t]rigger',
        expr = true,
        replace_keycodes = false,
      })

      keymap.set({ 'n', 'i' }, '<C-y>', suggestion.accept, {
        desc = 'Copilot accept suggestion',
        expr = true,
        replace_keycodes = false,
      })
    end,
  },
  -- TODO: enable soon
  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   dependencies = {
  --     { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
  --     { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  --   },
  --   build = "make tiktoken", -- Only on MacOS or Linux
  --   opts = {
  --     -- See Configuration section for options
  --   },
  --   -- See Commands section for default commands if you want to lazy load on them
  -- },
}
