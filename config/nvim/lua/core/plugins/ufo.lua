return {
	"kevinhwang91/nvim-ufo",
	cond = group.plugins.ufo,
	keys = {
		{
			"zR",
			function()
				require("ufo").openAllFolds()
			end,
			desc = "Open all UFO folds",
		},
		{
			"zM",
			function()
				require("ufo").closeAllFolds()
			end,
			desc = "Close all UFO folds",
		},
	},
	dependencies = { "kevinhwang91/promise-async" },
	opts = {},
}
