local M = {}

--- sets vim options based on table
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

--- create keybindings
---@param mode string | table: modes that the keybind is active in
---@param lhs string: the key presses needed
---@param rhs string | function: the action
---@param opts table?: options for the keybind
M.map = function(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

--- create new file, used for alpha buffer
M.create_new_file = function()
	local filename = vim.fn.input("Enter the filename: ")
	if filename ~= "" then
		vim.cmd("edit " .. filename)
	end
end

--- cmp autocompletion helper function
---@return boolean has_words: whether there are words before the cursor
M.has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

--- creates new terminals with ToggleTerm
---@param term Terminal: the toggleterm terminal
---@param cmd string: the command to run
---@return function|Terminal: the created terminal
M.create_floating_terminal = function(term, cmd)
	local instance = nil
	if vim.fn.executable(cmd) == 1 then
		local terminal = term.Terminal
		instance = terminal:new({
			cmd = cmd,
			dir = "git_dir",
			direction = "float",
			float_opts = {
				border = "double",
			},
			on_open = function()
				vim.cmd("startinsert!")
			end,
			on_close = function()
				vim.cmd("startinsert!")
			end,
		})
	end
	-- check if TermExec function exists
	return function()
		if vim.fn.executable(cmd) == 1 and instance ~= nil then
			instance:toggle()
		else
			vim.notify("Command not found: " .. cmd .. ". Ensure it is installed.", "error")
		end
	end
end

--- update all mason packages
M.update_mason = function()
	local registry = require("mason-registry")
	registry.refresh()
	registry.update()
	local packages = registry.get_all_packages()
	for _, pkg in ipairs(packages) do
		if pkg:is_installed() then
			pkg:install()
		end
	end
end

--- updates CyberNvim
M.update_all = function()
	vim.notify("Pulling latest changes...")
	vim.fn.jobstart({ "git", "pull", "--rebase" })
	require("lazy").sync({ wait = true })
	vim.notify("Updating Mason packages...")
	M.update_mason()
	require("nvim-treesitter")
	vim.cmd("TSUpdate")
	vim.notify("CyberNvim updated!", "info")
end

--- checks whether the attached LSP server supports formatting
---@return boolean is_supported: whether the server supports formatting
M.supports_formatting = function()
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		if client.supports_method("textDocument/formatting") then
			return true
		end
	end
	return false
end

--- whether the input is enabled in its table, for example a plugin in the plugin table
---@param group table: the table to look in
---@param opt string: the option to check
---@return boolean is_enabled: whether the option is enabled
M.enabled = function(group, opt)
	return group == nil or group[opt] == nil or group[opt] == true
end

--- whether the currently opening file is very big or not
---@param buf integer: the current buffer to check
---@return boolean is_big: if the file is above 100KB
M.large_file = function(buf)
	local max_filesize = 100 * 1024 -- 100 KB
	local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
	return ok and stats ~= nil and stats.size > max_filesize
end

local exist, user_config = pcall(require, "user_config")

--- enabled plugins
M.plugin_group = exist and type(user_config) == "table" and user_config.enable_plugins or {}

-- enabled autocommands
M.autocmd_group = exist and type(user_config) == "table" and user_config.autocommands or {}

return M
