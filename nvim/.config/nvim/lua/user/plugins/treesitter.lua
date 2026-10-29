return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      local ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'elixir',
        'erlang', 'zsh' }
      -- highlight disabled here: bash grammar highlight was flaky, keep vim regex highlighting instead;
      -- erlang: vim regex as base, elp semantic tokens layered on top
      local highlight_disabled = { bash = true, erlang = true }
      -- indent disabled here: ruby needs vim's regex-based indent, treesitter indent is still experimental
      local indent_disabled = { ruby = true }

      require('nvim-treesitter').install(ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          if highlight_disabled[ev.match] then
            return
          end
          local ok = pcall(vim.treesitter.start)
          if not ok then
            return
          end
          if not indent_disabled[ev.match] then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
