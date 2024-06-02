require("catppuccin").setup({
	integrations = {
		notify = true,
		alpha = true,
		lsp_trouble = true,
		dropbar = {
			enabled = true,
			color_mode = true,
		},
		hop = true,
		mason = true,
		noice = true,
		which_key = true,
		neotest = true,
	},
	dim_inactive = { enabled = true, percentage = 0.4 },
	flavour = "mocha",
	color_overrides = {
		mocha = {
			base = "#252525",
			mantle = "#262626",
			crust = "#252525",
		},
	},
})
