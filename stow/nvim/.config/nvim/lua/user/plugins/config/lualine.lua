local opts = {
  options = {
    icons_enabled = true,
    -- base16-* schemes (tinted-nvim) have no base16-colorscheme module, so lualine's
    -- built-in base16 theme errors; use tinted-nvim's own 'tinted' theme for those.
    -- Concrete themes (kanagawa, everforest) -> 'auto' generates a theme from hl groups.
    -- lualine re-evaluates a function theme on every ColorScheme.
    theme = function()
      local name = vim.g.colors_name or ''
      return name:sub(1, 6) == 'base16' and 'tinted' or 'auto'
    end,
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_c = {
      { 'filename', path = 1 },
    },
  },
}

require('lualine').setup(opts)
