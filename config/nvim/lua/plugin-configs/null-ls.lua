local null_ls = require("null-ls")

local ok, defaults = pcall(require, "defaults")
if not ok then
	vim.api.nvim_err_writeln("Failed to load defaults.lua")
end

require("mason").setup()
null_ls.setup({
	sources = defaults.setup_sources(null_ls.builtins),
})
