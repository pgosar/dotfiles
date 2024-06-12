return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	cmd = { "LspInfo", "LspInstall", "LspStart" },
	config = function()
		require("plugin-configs.lsp")
	end,
	dependencies = {
		{ "williamboman/mason-lspconfig.nvim" },
	},
}
