-- https://github.com/NeogitOrg/neogit
local neogit = require 'neogit'

neogit.setup {
  integrations = {
    snacks = true,
    diffview = true,
  },
}

-- '<localleader>ng' keymap moved to lua/user/keymaps.lua (section "Gitsigns"/neogit)
