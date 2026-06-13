-- Native session management replacing persistence.nvim
local M = {}
local session_dir = vim.fn.stdpath("state") .. "/sessions"
vim.fn.mkdir(session_dir, "p")

local function get_session_file()
  return session_dir .. "/" .. vim.fn.getcwd():gsub("/", "%%") .. ".vim"
end

function M.save_session()
  if not vim.g.disable_session_save and vim.fn.argc() == 0 then
    local session_file = get_session_file()
    vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
  end
end

function M.load_session()
  local file = get_session_file()
  if vim.fn.filereadable(file) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(file))
  else
    vim.notify("No session found for this directory.")
  end
end

function M.load_last_session()
  local files = vim.fn.glob(session_dir .. "/*.vim", false, true)
  if #files == 0 then
    vim.notify("No sessions found.")
    return
  end
  table.sort(files, function(a, b) return vim.fn.getftime(a) > vim.fn.getftime(b) end)
  vim.cmd("source " .. vim.fn.fnameescape(files[1]))
end

function M.stop_session()
  vim.g.disable_session_save = true
  vim.notify("Session saving disabled for this session.")
end

return M
