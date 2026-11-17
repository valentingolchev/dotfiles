-- tinted-nvim first-boot race fix: if current_scheme file was missing at startup,
-- its fs watcher never attached and the default_scheme stayed active. Re-resolve on VimEnter.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local ok, tn = pcall(require, "tinted-nvim")
    if not ok then return end
    local f = vim.fn.expand("~/.local/share/tinted-theming/tinty/current_scheme")
    if vim.fn.filereadable(f) == 1 then
      local scheme = vim.fn.readfile(f)[1]
      if scheme and scheme ~= "" and scheme ~= vim.g.colors_name then
        pcall(tn.load, scheme)
      end
    end
  end,
})
