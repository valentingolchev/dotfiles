return {
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        watch_for_changes = true,
        -- Buffer keymaps moved to lua/user/keymaps.lua (section "Oil")
        view_options = {
          show_hidden = true,
        },
      }
    end,
  },
}
