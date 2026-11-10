-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out,                            'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.runtimepath:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup {
  spec = {
    -- tinted-nvim follows tinty's current scheme (mode=file + watch=true are
    -- defaults — it watches the current_scheme file tinty writes);
    -- base16-kanagawa-dragon is the fallback when no scheme is set.
    { "tinted-theming/tinted-nvim", lazy = false, priority = 1000, opts = { default_scheme = "base16-kanagawa-dragon", selector = { enabled = true } } },
    -- Keep kanagawa installed (tinted-nvim drives the active colorscheme;
    -- kanagawa kept for manual `:colorscheme kanagawa` (no auto-setup; themes/ file removed, tinty owns colorschemes))
    'rebelot/kanagawa.nvim',
    { import = 'user.plugins' },
  },
  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = false,
    notify = true, -- get a notification when changes are found
  },
  ui = {
    border = 'single',
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}
