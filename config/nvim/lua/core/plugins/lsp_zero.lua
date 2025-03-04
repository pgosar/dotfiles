return {
	"VonHeikemen/lsp-zero.nvim",
	cond = group.plugins.lsp_zero,
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "gD", vim.lsp.buf.declaration, desc = "Go to Declaration" },
		{ "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
		{ "gi", vim.lsp.buf.implementation, desc = "Go to Implementation" },
		{ "<leader>rn", vim.lsp.buf.rename, desc = "Rename Symbol" },
		{ "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" }, desc = "Code Action" },
		{
			"<C-h>",
			function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
			end,
			desc = "Toggle Inlay Hints",
		},
	},
	branch = "v4.x",
}
