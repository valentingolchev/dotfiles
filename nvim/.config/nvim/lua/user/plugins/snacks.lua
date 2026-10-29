-- Mermaid renders in an unsandboxed Chromium (AppArmor blocks its sandbox), so
-- it only runs on demand. Without the flag, mmdc keeps the sandbox and fails,
-- which also covers buffers snacks attaches on its own, like picker previews.
local function mermaid_args()
  local theme = vim.o.background == 'light' and 'neutral' or 'dark'
  local args = { '-i', '{src}', '-o', '{file}', '-b', 'transparent', '-t', theme, '-s', '{scale}' }
  if vim.g.mermaid_unsandboxed then
    vim.list_extend(args, { '-p', vim.fn.stdpath 'config' .. '/mermaid-puppeteer.json' })
  end
  return args
end

return {
  {
    'folke/snacks.nvim',
    opts = {
      image = {
        enabled = true,
        doc = { enabled = false },
        convert = { notify = true, mermaid = mermaid_args },
      },
    },
    keys = {
      {
        '<leader>im',
        function()
          vim.g.mermaid_unsandboxed = true
          Snacks.notify('Rendering images', { title = 'Markdown' })
          -- Real buffer number: snacks looks up windows by it, and 0 matches none.
          Snacks.image.doc.attach(vim.api.nvim_get_current_buf())
        end,
        desc = 'Render images and mermaid in buffer',
      },
    },
  },
}
