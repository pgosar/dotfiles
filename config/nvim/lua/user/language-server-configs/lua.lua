require("lspconfig").lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = {
				disable = { "missing-fields" },
			},
			hint = {
				enable = true,
			},
		},
	},
})
