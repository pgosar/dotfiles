local augroup = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd

local exist, user_config = pcall(require, "user.user_config")
local group = exist and type(user_config) == "table" and user_config.autocommands or {}
local enabled = require("core.utils.utils").enabled

if enabled(group, "term_spelling") then
	cmd({ "TermOpen" }, {
		desc = "disable spellcheck in terminal buffers",
		group = augroup("disable_spell", { clear = true }),
		pattern = "*",
		command = "setlocal nospell",
	})
end
