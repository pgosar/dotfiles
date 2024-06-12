return {
	"folke/zen-mode.nvim",
	cond = group.plugins.zen,
	cmd = "ZenMode",
	config = function()
		require("plugin-configs.zenmode")
	end,
}
