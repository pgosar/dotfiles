return {
	"folke/trouble.nvim",
	cond = group.plugins.trouble,
	cmd = "Trouble",
	config = function()
		require("plugin-configs.trouble")
	end,
}
