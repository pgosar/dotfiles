return {
	"akinsho/bufferline.nvim",
	cond = group.plugins.bufferline,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.bufferline")
	end,
}
