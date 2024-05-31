local augroup = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd

local exist, user_config = pcall(require, "user_config")
local group = exist and type(user_config) == "table" and user_config.autocommands or {}
local enabled = require("core.utils.utils").enabled

-- Removes any trailing whitespace when saving a file
if enabled(group, "trailing_whitespace") then
	cmd({ "BufWritePre" }, {
		desc = "remove trailing whitespace on save",
		group = augroup("remove trailing whitespace", { clear = true }),
		pattern = { "*" },
		command = [[%s/\s\+$//e]],
	})
end

-- remembers file state, such as cursor position and any folds
if enabled(group, "remember_file_state") then
	augroup("remember file state", { clear = true })
	cmd({ "BufWinLeave" }, {
		desc = "remember file state",
		group = "remember file state",
		pattern = { "*.*" },
		command = "mkview",
	})
	cmd({ "BufWinEnter" }, {
		desc = "remember file state",
		group = "remember file state",
		pattern = { "*.*" },
		command = "silent! loadview",
	})
end

-- gives you a notification upon saving a session
if enabled(group, "session_saved_notification") then
	cmd({ "User" }, {
		desc = "notify session saved",
		group = augroup("session save", { clear = true }),
		pattern = "SessionSavePost",
		command = "lua vim.notify('Session Saved', 'info')",
	})
end

-- fixes Trouble not closing when last window in tab
if enabled(group, "trouble") then
	cmd("BufEnter", {
		desc = "close trouble when last window in tab",
		group = vim.api.nvim_create_augroup("TroubleClose", { clear = true }),
		callback = function()
			local layout = vim.api.nvim_call_function("winlayout", {})
			if
				layout[1] == "leaf"
				and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "trouble"
				and layout[3] == nil
			then
				vim.cmd("confirm quit")
			end
		end,
	})
end

-- no spellcheck in terminal buffers
if enabled(group, "term_spelling") then
	cmd({ "TermOpen" }, {
		desc = "disable spellcheck in terminal buffers",
		group = augroup("disable_spell", { clear = true }),
		pattern = "*",
		command = "setlocal nospell",
	})
end
