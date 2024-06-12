return {
	"folke/noice.nvim",
	cond = group.plugins.noice,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.noice")
	end,
	dependencies = { { "MunifTanjim/nui.nvim" } },
}
