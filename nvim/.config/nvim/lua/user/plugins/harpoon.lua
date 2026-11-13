return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local harpoon = require 'harpoon'

      -- REQUIRED
      harpoon:setup()
      -- REQUIRED

      -- Global keymaps moved to lua/user/keymaps.lua (section "Harpoon")

      -- Extentions
      local extensions = require 'harpoon.extensions'

      harpoon:extend(extensions.builtins.navigate_with_number())
      harpoon:extend(extensions.builtins.highlight_current_file())

      harpoon:extend {
        -- Buffer keymaps for the quick menu live in lua/user/keymaps.lua
        -- (M.harpoon_ui_create)
        UI_CREATE = function(cx)
          require('user.keymaps').harpoon_ui_create(cx)
        end,
      }
    end,
  },
}
