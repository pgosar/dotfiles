return {
	"hrsh7th/nvim-cmp",
	cond = group.plugins.cmp,
	event = { "InsertEnter", "CmdlineEnter" },
	config = function()
		require("plugin-configs.cmp")
	end,
	dependencies = {
		{ "onsails/lspkind.nvim" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-cmdline" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-nvim-lua" },
		{
			"garymjr/nvim-snippets",
			opts = { friendly_snippets = true },
			dependencies = { { "rafamadriz/friendly-snippets" } },
		},
	},
}
