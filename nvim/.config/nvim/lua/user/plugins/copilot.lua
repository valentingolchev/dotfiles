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
        desc = '[C]opilot suggestion [t]oggle auto [t]rigger',
        expr = true,
        replace_keycodes = false,
      })

      keymap.set({ 'n', 'i' }, '<C-y>', suggestion.accept, {
        desc = 'Copilot suggestion accept',
        expr = true,
        replace_keycodes = false,
      })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
    config = function()
      local chat = require 'CopilotChat'

      -- example config: https://github.com/deathbeam/dotfiles/blob/master/nvim/.config/nvim/lua/config/copilot.lua
      -- setup --
      chat.setup {
        -- See Configuration section for options
      }

      -- keymaps --
      vim.keymap.set('n', '<leader>occ', '<cmd>:CopilotChatOpen<CR>', { desc = '[Open] [c]opilot [c]hat window' })
      vim.keymap.set({ 'n', 'v' }, '<leader>pcc', '<cmd>:CopilotChatPrompts<CR>', { desc = 'Choose [p]rompts for [c]opilot [c]hat' })
    end,
  },
}
