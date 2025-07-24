-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
vim.opt.termguicolors = true

require 'user.options'
require 'user.config'
require 'user.lazy'

require 'user.plugins.custom.floaterm'

-- Keymaps should be loaded it the end
-- to make sure the correct <leader> and <localleader> are set
require 'user.keymaps'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
