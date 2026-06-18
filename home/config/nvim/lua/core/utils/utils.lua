-- Utility functions
local M = {}

--- Sets vim options based on table
---@param options table: options to set
M.vim_opts = function(options)
  if options ~= nil then
    for scope, table in pairs(options) do
      for setting, value in pairs(table) do
        vim[scope][setting] = value
      end
    end
  end
end

--- Create keybindings
---@param mode string | table: modes that the keybind is active in
---@param lhs string: the key presses needed
---@param rhs string | function: the action
---@param opts table?: options for the keybind
M.map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

--- Creates an augroup
---@param name string: the name of the augroup
---@param opts table?: options for the augroup
M.augroup = function(name, opts)
  local options = { clear = true }
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.api.nvim_create_augroup(name, options)
end

--- Create new file, used for alpha buffer
M.create_new_file = function()
  local filename = vim.fn.input("Enter the filename: ")
  if filename ~= "" then vim.cmd("edit " .. filename) end
end

--- Update all mason packages
M.update_mason = function()
  if not require("core.utils.plugins").load("mason") then return end

  local registry = require("mason-registry")
  registry.refresh()
  registry.update()
  local packages = registry.get_all_packages()
  for _, pkg in ipairs(packages) do
    if pkg:is_installed() then pkg:install() end
  end
end

--- Update plugins in pack directories
M.update_plugins = function()
  local plugin_dirs = {}

  for _, plugin in ipairs(require("core.plugins")) do
    local package_type = plugin.lazy and "opt" or "start"
    local dir = vim.fn.stdpath("config") .. "/pack/plugins/" .. package_type .. "/" .. plugin.name
    if vim.fn.isdirectory(dir) == 1 then table.insert(plugin_dirs, dir) end
  end

  vim.notify("Updating plugins...")
  local count = 0
  for _, dir in ipairs(plugin_dirs) do
    local name = vim.fs.basename(dir)
    local stderr = {}
    vim.fn.jobstart({ "git", "pull" }, {
      cwd = dir,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stderr = function(_, data)
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(stderr, line) end
        end
      end,
      on_exit = function(_, code)
        if code ~= 0 then
          local err_msg = #stderr > 0 and table.concat(stderr, "\n") or "Unknown error"
          vim.notify("Failed to update " .. name .. ":\n" .. err_msg, vim.log.levels.WARN)
        end
      end,
    })
    count = count + 1
  end
  vim.notify("Queued updates for " .. count .. " plugins.")
end

--- Updates CyberNvim
M.update_all = function()
  vim.notify("Pulling latest dotfiles changes...")
  local stderr = {}
  vim.fn.jobstart({ "git", "pull", "--rebase" }, {
    cwd = vim.fn.stdpath("config"),
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then table.insert(stderr, line) end
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("Dotfiles updated successfully.")
      else
        local err_msg = #stderr > 0 and table.concat(stderr, "\n") or "Unknown error"
        vim.notify("Failed to pull latest dotfiles:\n" .. err_msg, vim.log.levels.ERROR)
      end
      M.update_plugins()

      if require("core.utils.plugins").enabled("mason") then
        vim.notify("Updating Mason packages...")
        local pcall_ok, err = pcall(M.update_mason)
        if not pcall_ok then
          vim.notify("Failed to update Mason packages: " .. tostring(err), vim.log.levels.WARN)
        end
      end

      if require("core.utils.plugins").enabled("nvim_treesitter") then vim.cmd("TSUpdate") end
      vim.notify("CyberNvim updated!", vim.log.levels.INFO)
    end,
  })
end

--- Checks whether the attached LSP server supports formatting
---@return boolean is_supported: whether the server supports formatting
M.supports_formatting = function()
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/formatting") then return true end
  end
  return false
end

--- Whether the currently opening file is very big or not
---@param buf integer: the current buffer to check
---@return boolean is_big: if the file is above configured big-file threshold
M.large_file = function(buf)
  local settings = require("defaults").settings
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  return settings.bigfile_enable and ok and stats ~= nil and stats.size > settings.bigfile_threshold
end

--- Set the current working directory to the root of the project
M.set_root = function()
  -- Get directory path to start search from
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then return end
  path = vim.fs.dirname(path)

  local root_file = vim.fs.find({ ".git", ".gitignore" }, { path = path, upward = true })[1]
  if root_file == nil then return end
  local root = vim.fs.dirname(root_file)
  -- Set current directory
  vim.fn.chdir(root)
end

--- Truncates messages to the last complete line that fits within the max length
---@param message string: the message to truncate
---@param max_length integer: the maximum length of the message
M.truncate_message = function(message, max_length)
  if #message <= max_length then return message end

  -- Find the last newline before the max length
  local break_point = message:sub(1, max_length):match(".*()\n")
  if break_point then
    return message:sub(1, break_point) .. "..."
  else
    -- If no newline exists within the limit, truncate normally
    return message:sub(1, max_length - 3) .. "..."
  end
end

--- Closes all floating windows
M.close_floating_windows = function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then vim.api.nvim_win_close(win, true) end
  end
end

return M
