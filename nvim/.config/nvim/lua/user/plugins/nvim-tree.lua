return {
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      -- recommended settings from nvim-tree documentation
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      local nvimtree = require 'nvim-tree'

      nvimtree.setup {
        view = {
          width = 35,
          relativenumber = true,
        },
        -- change folder arrow icons
        renderer = {
          indent_markers = {
            enable = true,
          },
          icons = {
            glyphs = {
              folder = {
                arrow_closed = '', -- arrow when folder is closed
                arrow_open = '', -- arrow when folder is open
              },
            },
          },
        },
        filters = {
          custom = { '.DS_Store' },
        },
        git = {
          ignore = false,
        },
      }

      -- set keymaps
      local keymap = vim.keymap -- for conciseness

      keymap.set('n', 'C-n', ':NvimTreeFindFileToggle<CR>')
      keymap.set('n', '<leader>te', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' }) -- toggle file explorer
      keymap.set('n', '<leader>tf', '<cmd>NvimTreeFindFileToggle<CR>', { desc = 'Toggle file explorer on current file' }) -- toggle file explorer on current file
      keymap.set('n', '<leader>tc', '<cmd>NvimTreeCollapse<CR>', { desc = 'Collapse file explorer' }) -- collapse file explorer
      keymap.set('n', '<leader>tr', '<cmd>NvimTreeRefresh<CR>', { desc = 'Refresh file explorer' })
    end,
  },
  { 'nvim-tree/nvim-web-devicons' },
}
