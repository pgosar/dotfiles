return {
	"folke/trouble.nvim",
	cond = group.plugins.trouble,
	keys = {
		{ "<leader>tf", "<CMD>Trouble toggle diagnostics<CR>", desc = "Trouble toggle diagnostics" },
		{ "<leader>tt", "<CMD>Trouble toggle todo<CR>", desc = "Trouble toggle todo" },
		{ "<leader>ts", "<CMD>Trouble toggle symbols<CR>", desc = "Trouble toggle symbols" },
		{ "<leader>tl", "<CMD>Trouble toggle lsp<CR>", desc = "Trouble toggle lsp" },
	},
	cmd = "Trouble",
	opts = {
		focus = true,
	},
}
