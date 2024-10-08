return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha', -- mocha, macchiato, frappe, latte
      transparent_background = true,
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { 'italic' }, -- Change the style of comments
      },
    }

    vim.o.termguicolors = true

    -- setup must be called before loading
    vim.cmd.colorscheme 'catppuccin'
  end,
}
