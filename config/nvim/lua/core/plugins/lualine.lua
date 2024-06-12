return {
	"lvim-lualine/lualine.nvim",
	event = "VeryLazy",
	cond = group.plugins.lualine,
	config = function()
		require("plugin-configs.lualine")
	end,
}
