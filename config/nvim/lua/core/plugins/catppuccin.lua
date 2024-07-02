return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	cond = group.plugins.catppuccin,
	config = function()
		local colors = require("defaults").colors.mocha_override
		require("catppuccin").setup({
			integrations = {
				alpha = true,
				dropbar = {
					color_mode = true,
					enabled = true,
				},
				gitsigns = true,
				hop = true,
				illuminate = { enabled = true },
				lsp_trouble = true,
				mason = true,
				neotest = true,
				noice = true,
				notify = true,
				rainbow_delimiters = true,
				telescope = { enabled = true },
				which_key = true,
			},
			dim_inactive = { enabled = true, percentage = 0.4 },
			flavour = "mocha",
			color_overrides = {
				mocha = {
					base = colors.base,
					mantle = colors.mantle,
					crust = colors.crust,
				},
			},
		})
	end,
}
