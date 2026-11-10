local M = {}

local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local function create_buffer(opts)
  if vim.api.nvim_buf_is_valid(opts.buf) then
    return opts.buf
  end

  return vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
end

local function create_floating_window(opts)
  opts = opts or {}

  local buf = create_buffer(opts)

  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  -- Define window configuration
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    -- style = 'minimal', -- No borders or extra UI elements
    border = 'rounded',
  }

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local function delete_terminal()
  if vim.api.nvim_win_is_valid(state.floating.win) then
    vim.api.nvim_win_close(state.floating.win, true)
  end
  if vim.api.nvim_buf_is_valid(state.floating.buf) then
    vim.api.nvim_buf_delete(state.floating.buf, { force = true })
  end
  state.floating.buf = -1
  state.floating.win = -1
end

local LUALINE_STATUSLINE = "%{%v:lua.require('lualine').statusline()%}"

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    vim.wo[state.floating.win].statusline = LUALINE_STATUSLINE
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
      -- close the floating window and wipe the buffer once the shell exits (e.g. typing 'exit')
      vim.api.nvim_create_autocmd('TermClose', {
        buffer = state.floating.buf,
        callback = function()
          vim.defer_fn(delete_terminal, 100)
        end,
      })
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

-- Example usage:
-- Create a floating window with default dimensions
vim.api.nvim_create_user_command('Floaterminal', toggle_terminal, {})

return M
