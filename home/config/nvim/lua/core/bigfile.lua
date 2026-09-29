-- Big-file fast path: only the minimal options below are set, nothing else.
local M = {}

-- The only options set in big-file mode.
M.minimal_opts = {
  autowrite = true,
  undofile = true,
  clipboard = "unnamedplus",
  cursorline = true,
  cursorlineopt = "number",
  ignorecase = true,
  laststatus = 3,
  number = true,
  scrolloff = 5,
  foldlevel = 99,
  foldlevelstart = 99,
  softtabstop = 2,
}

-- True if any CLI arg is an existing file over the size threshold.
M.is_bigfile = function()
  local settings = require("defaults").settings
  if not settings.bigfile_enable then return false end
  for _, path in ipairs(vim.fn.argv()) do
    local ok, stats = pcall(vim.uv.fs_stat, path)
    if ok and stats and stats.type == "file" and stats.size > settings.bigfile_threshold then
      return true
    end
  end
  return false
end

-- Apply only the minimal options table.
M.setup = function()
  for setting, value in pairs(M.minimal_opts) do
    vim.opt[setting] = value
  end
end

return M
