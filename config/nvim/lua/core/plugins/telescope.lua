return {
	"nvim-telescope/telescope.nvim",
	cond = group.plugins.telescope,
	cmd = "Telescope",
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		{ "nvim-lua/plenary.nvim" },
	},
	config = function()
		require("plugin-configs.telescope")
	end,
}
