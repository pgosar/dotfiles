-- Big-file fast path: when Neovim opens a huge file from the CLI, apply only
-- the minimal options below and skip the entire normal config (no plugins,
-- no LSP, no autocommands). Checked from init.lua before core_init loads.
local M = {}

-- The only options applied in big-file mode. Nothing else is set.
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

--- Whether path is an existing file above the big-file threshold
---@param path string: file path to check (may be empty or nonexistent)
---@return boolean is_big: true if the file exists and exceeds the threshold
M.is_bigfile = function(path)
  if path == nil or path == "" then return false end
  local settings = require("defaults").settings
  if not settings.bigfile_enable then return false end
  local ok, stats = pcall(vim.uv.fs_stat, path)
  return ok and stats ~= nil and stats.type == "file"
    and stats.size > settings.bigfile_threshold
end

--- Apply only the minimal options; called instead of the normal init
M.setup = function()
  vim.g.bigfile_mode = true
  for setting, value in pairs(M.minimal_opts) do
    vim.opt[setting] = value
  end
end

return M
