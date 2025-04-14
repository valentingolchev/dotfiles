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
          suggestion = { enabled = false },
          panel = { enabled = false },
          filetypes = { ['*'] = true },
        },
      }
    end,
  },
  -- {
  --   'zbirenbaum/copilot-cmp',
  --   dependecies = { 'zbirenbaum/copilot.lua' },
  --   config = function()
  --     require('copilot_cmp').setup()
  --   end,
  -- },
  -- {
  --   -- https://github.com/github/copilot.vim
  --   'github/copilot.vim',
  --   config = function()
  --     -- keymaps
  --     local keymap = vim.keymap
  --     keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
  --       expr = true,
  --       replace_keycodes = false,
  --     })
  --
  --     vim.g.copilot_no_tab_map = true
  --   end,
  -- },
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
