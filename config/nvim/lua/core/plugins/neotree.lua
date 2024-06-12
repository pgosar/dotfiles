return {
	"nvim-neo-tree/neo-tree.nvim",
	cond = group.plugins.neotree,
	event = "VeryLazy",
	config = function()
		require("plugin-configs.neo-tree")
	end,
	branch = "v3.x",
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
