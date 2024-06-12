return {
	"epwalsh/obsidian.nvim",
	cond = group.plugins.obsidian,
	ft = "markdown",
	config = function()
		require("plugin-configs.obsidian")
	end,
}
