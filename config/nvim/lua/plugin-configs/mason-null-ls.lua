local ok, defaults = pcall(require, "defaults")
if not ok then
	vim.api.nvim_err_writeln("Failed to load defaults.lua")
end

require("mason-null-ls").setup({
	ensure_installed = defaults.mason_ensure_installed.null_ls,
	automatic_installation = true,
})
