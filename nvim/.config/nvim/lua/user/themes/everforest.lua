return {
  -- https://github.com/neanias/everforest-nvim
  'neanias/everforest-nvim',
  priority = 1000,
  config = function()
    local everforest = require("everforest")
    everforest.setup {
      background = "soft",
      transparent_background_level = 0,
      italics = true,
      disable_italic_comments = false,
      inlay_hints_background = "dimmed",
      on_highlights = function(hl, palette)
        hl["@string.special.symbol.ruby"] = { link = "@field" }
        hl["DiagnosticUnderlineWarn"] = { undercurl = true, sp = palette.yellow }
      end,
    }

    everforest.load()
    -- setup must be called before loading
    vim.cmd.colorscheme 'everforest'
  end,
}
