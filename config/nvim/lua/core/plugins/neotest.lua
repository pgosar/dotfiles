return {
	"nvim-neotest/neotest",
	cond = group.plugins.neotest,
	keys = {
		{
			"<leader>nr",
			function()
				require("neotest").run.run()
			end,
			desc = "run test with neotest",
		},
	},
	opts = {},
}
