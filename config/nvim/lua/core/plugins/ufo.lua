return {
	"kevinhwang91/nvim-ufo",
	cond = group.plugins.ufo,
	event = "VeryLazy",
	keys = {
		{
			"zR",
			function()
				require("nvim-ufo").openAllFolds()
			end,
			desc = "Open all UFO folds",
		},
		{
			"zM",
			function()
				require("nvim-ufo").closeAllFolds()
			end,
			desc = "Close all UFO folds",
		},
	},
	dependencies = "kevinhwang91/promise-async",
	config = true,
}
