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

for _, source in ipairs({
	"core.main-options",
	"core.plugins",
	"core.keybindings",
	"core.utils.utils",
	"core.utils.notify",
	"core.autocommands",
}) do
	local status_ok, fault = pcall(require, source)
	if not status_ok then
		vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault)
	end
end

local enabled = require("core.utils.utils").enabled
local exist, user_config = pcall(require, "user_config")
local group = exist and type(user_config) == "table" and user_config.enable_plugins or {}

if enabled(group, "notify") then
	vim.notify = require("notify")
end

-- update function
vim.api.nvim_create_user_command("CyberUpdate", function()
	require("core.utils.utils").update_all()
end, { desc = "Updates plugins, mason packages, treesitter parsers" })

-- fix commentstrings to work with native nvim commenting
if enabled(group, "treesitter") then
	local get_option = vim.filetype.get_option
	vim.filetype.get_option = function(filetype, option)
		return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
			or get_option(filetype, option)
	end
end

-- setup spellcheck
local spell_words = {}
for word in io.open(vim.fn.stdpath("config") .. "/spell/en.utf-8.add", "r"):lines() do
	table.insert(spell_words, word)
end

local ok, _ = pcall(vim.cmd.colorscheme, user_config.colorscheme)
if not ok then
	vim.cmd.colorscheme("default")
end

vim.diagnostic.config({
	update_in_insert = false,
})
