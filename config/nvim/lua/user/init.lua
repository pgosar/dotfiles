require("user.language-server-configs.ls_init")
require("user.keybindings")
require("user.autocommands")

local treesitter_ok, _ = pcall(require, "nvim-treesitter")
local lsp_ok, _ = pcall(require, "lsp-zero")

if treesitter_ok then
	require("user.plugin-configs.treesitter")
end

if lsp_ok then
	require("user.plugin-configs.lspconfig")
end

-- setup spellcheck
local spell_words = {}
for word in io.open(vim.fn.stdpath("config") .. "/spell/en.utf-8.add", "r"):lines() do
	table.insert(spell_words, word)
end

vim.cmd.colorscheme("catppuccin")
