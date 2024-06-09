local augroup = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd

local autocmd_group = require("core.utils.utils").autocmd_group
local enabled = require("core.utils.utils").enabled

-- Removes any trailing white space when saving a file
if enabled(autocmd_group, "trailing_whitespace") then
	cmd({ "BufWritePre" }, {
		desc = "remove trailing whitespace on save",
		group = augroup("remove trailing whitespace", { clear = true }),
		pattern = { "*" },
		command = [[%s/\s\+$//e]],
	})
end

-- remembers file state, such as cursor position and any folds
if enabled(autocmd_group, "remember_file_state") then
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

-- no spellcheck in terminal buffers
if enabled(autocmd_group, "term_spelling") then
	cmd({ "TermOpen" }, {
		desc = "disable spellcheck in terminal buffers",
		group = augroup("disable_spell", { clear = true }),
		pattern = "*",
		command = "setlocal nospell",
	})
end

if enabled(autocmd_group, "number") then
	cmd({ "VimEnter", "InsertLeave" }, {
		desc = "set relativenumber",
		group = augroup("set_relativenumber", { clear = true }),
		pattern = "*",
		command = "set relativenumber",
	})
	cmd({ "InsertEnter" }, {
		desc = "set number",
		group = augroup("set_number", { clear = true }),
		pattern = "*",
		command = "set number norelativenumber",
	})
end
