return {
  -- https://github.com/catppuccin/nvim
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    integrations = { blink_cmp = true },
  },
  config = function()
    require('catppuccin').setup {
      flavour = 'frappe', -- mocha, macchiato, frappe, latte
      transparent_background = true,
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { 'italic' }, -- Change the style of comments
      },
      integrations = {
        blink_cmp = true,
        cmp = false, -- default is 'true'
        harpoon = true,
        mason = true,
        noice = true,
        which_key = true,
      },
    }

    vim.o.termguicolors = true

    -- setup must be called before loading
    vim.cmd.colorscheme 'catppuccin'
  end,
}
