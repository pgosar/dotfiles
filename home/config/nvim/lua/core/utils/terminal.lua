-- Native floating terminal toggle replacing toggleterm.nvim
local M = {}
local term_state = {}

function M.toggle_terminal(cmd)
  cmd = cmd or "shell"
  local s = term_state[cmd] or {}
  term_state[cmd] = s

  -- 1. Close window if it's currently open and valid
  if s.win and vim.api.nvim_win_is_valid(s.win) then
    vim.api.nvim_win_close(s.win, true)
    s.win = nil
    return
  end

  -- 2. Create buffer if it doesn't exist
  if not s.buf or not vim.api.nvim_buf_is_valid(s.buf) then
    s.buf = vim.api.nvim_create_buf(false, true)
  end

  -- 3. Calculate dimension and row/col (80% width/height, centered)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- 4. Open floating window
  s.win = vim.api.nvim_open_win(s.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- 5. Set terminal buffer options
  vim.wo[s.win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  -- 6. Open shell or cmd in terminal if not already running
  if vim.bo[s.buf].buftype ~= "terminal" then
    vim.fn.jobstart(cmd == "shell" and vim.o.shell or cmd, { term = true })
  end
  vim.cmd("startinsert")
end

return M
