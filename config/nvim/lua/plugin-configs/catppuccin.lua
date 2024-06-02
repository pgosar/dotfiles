require("catppuccin").setup({
	integrations = {
		notify = true,
		alpha = true,
		lsp_trouble = true,
	},
	dim_inactive = { enabled = true, percentage = 0.5 },
	flavour = "mocha",
	color_overrides = {
		mocha = {
			base = "#252525",
			mantle = "#252525",
			crust = "#252525",
		},
	},
})
