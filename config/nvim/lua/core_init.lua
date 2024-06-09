local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)
local big_file = require("core.utils.utils").large_file(vim.api.nvim_get_current_buf())
for _, source in ipairs({
	"core.main-options",
	"core.plugins",
	"core.keybindings",
	"core.utils.utils",
	"core.utils.notify",
	"core.autocommands",
}) do
	if not big_file then
		local status_ok, fault = pcall(require, source)
		if not status_ok then
			vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault)
		end
	end
end

local ok, defaults = pcall(require, "defaults")
if not ok then
	vim.api.nvim_err_writeln("Failed to load defaults.lua")
end
local group = defaults.group

if group.plugins.notify then
	_, vim.notify = pcall(require, "notify")
end

-- update function
vim.api.nvim_create_user_command("CyberUpdate", function()
	require("core.utils.utils").update_all()
end, { desc = "Updates plugins, mason packages, treesitter parsers" })

-- fix comment strings to work with native nvim commenting
if group.plugins.treesitter then
	local get_option = vim.filetype.get_option
	vim.filetype.get_option = function(filetype, option)
		local ok, ts_context_commentstring_internal = pcall(require, "ts_context_commentstring.internal")
		if ok and option == "commentstring" then
			return ts_context_commentstring_internal.calculate_commentstring()
		else
			return get_option(filetype, option)
		end
	end
end

-- setup spellcheck
local spell_words = {}
for word in io.open(vim.fn.stdpath("config") .. "/spell/en.utf-8.add", "r"):lines() do
	table.insert(spell_words, word)
end

local ok, _ = pcall(vim.cmd.colorscheme, require("defaults").colorscheme)
if not ok then
	vim.cmd.colorscheme("default")
end

-- only update LSP diagnostic information when leaving insert mode
vim.diagnostic.config({
	update_in_insert = false,
})

-- set essential options if file is very big
if big_file then
	local vim_opts = require("core.utils.utils").vim_opts
	vim_opts({
		opt = {
			clipboard = "unnamedplus",
			cursorline = true,
			cursorlineopt = "number",
			ignorecase = true,
			laststatus = 3,
			number = true,
			scrolloff = 5,
		},
	})
end

-- TODO:
-- light mode/ dark mode switcher
-- massive refactor all plugins into separate files and aggressively lazyload
