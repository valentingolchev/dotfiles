return {
  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = false, --not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        clojure = { 'cljkondo', 'cljfmt' },
        erlang = { 'erlfmt' },
        elixir = { 'mix' },

        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
      formatters = {
        mix = {
          -- Umbrellas keep their only .formatter.exs at the repo root, while
          -- the builtin looks for the nearest mix.exs (an app dir). Checked in
          -- two steps: one list would stop at whichever marker is found first.
          cwd = function(self, ctx)
            local util = require('conform.util')
            return util.root_file { '.formatter.exs' }(self, ctx)
              or util.root_file { 'mix.exs' }(self, ctx)
          end,
          require_cwd = true,
        },
        cljkondo = {
          -- Change where to find the command
          command = 'opt/homebrew/bin/clj-kondo',
        },
        erlfmt = {
          command = 'erlfmt',
        },
      },
    },
  },
}
