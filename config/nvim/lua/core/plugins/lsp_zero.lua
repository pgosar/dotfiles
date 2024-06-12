return {
	"VonHeikemen/lsp-zero.nvim",
	cond = group.plugins.lsp_zero,
	event = { "BufReadPre", "BufNewFile" },
	branch = "v3.x",
	dependencies = {},
}
