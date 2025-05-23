return {
  {
    -- https://github.com/lewis6991/gitsigns.nvim
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Git (un)[s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Git [r]eset hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git (un)[s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git [S]tage buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git [p]review hunk' })
        map('n', '<leader>hpi', gitsigns.preview_hunk_inline, { desc = 'Git [p]review hunk inline' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git [b]lame line' })
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'Git [D]iff against last commit' })
        -- Toggles
      end,
    },
  },
  -- https://github.com/NeogitOrg/neogit
  {
    'NeogitOrg/neogit',
    dependencies = {
      -- required
      'nvim-lua/plenary.nvim',

      -- optional
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local neogit = require 'neogit'

      neogit.setup {
        integrations = {
          telescope = true,
          diffview = true,
        },
      }

      vim.keymap.set('n', '<localleader>ng', '<cmd>Neogit<cr>', { desc = 'Open [N]eo[G]it status window' })
    end,
  },
}
