return {
  -- https://github.com/rebelot/kanagawa.nvim
  'rebelot/kanagawa.nvim',
  priority = 1000,
  config = function()
    require('kanagawa').setup {
      theme = 'lotus',
      background = {
        dark = 'wave',
        light = 'lotus',
      },
    }

    -- setup must be called before loading
    vim.cmd.colorscheme 'kanagawa'
  end,
}
