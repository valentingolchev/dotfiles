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
      -- vim.keymap.set('n', '<leader>occ', '<cmd>:CopilotChatOpen<CR>', { desc = '[Open] [c]opilot [c]hat window' })
      -- vim.keymap.set({ 'n', 'v' }, '<leader>pcc', '<cmd>:CopilotChatPrompts<CR>', { desc = 'Choose [p]rompts for [c]opilot [c]hat' })
      vim.keymap.set({ 'n' }, '<leader>aa', chat.toggle, { desc = '[A]I Toggle' })
      vim.keymap.set({ 'v' }, '<leader>aa', chat.open, { desc = '[A]I Open' })
      vim.keymap.set({ 'n' }, '<leader>ax', chat.reset, { desc = '[A]I [R]eset' })
      vim.keymap.set({ 'n' }, '<leader>as', chat.stop, { desc = '[A]I [S]top' })
      vim.keymap.set({ 'n' }, '<leader>am', chat.select_model, { desc = '[A]I [M]odels' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ap', chat.select_prompt, { desc = '[A]I [P]rompts' })
      vim.keymap.set({ 'n', 'v' }, '<leader>aq', function()
        vim.ui.input({ prompt = 'AI Question> ' }, function(input)
          if input ~= '' then
            chat.ask(input)
          end
        end)
      end, { desc = 'AI Question' })
    end,
  },
}
