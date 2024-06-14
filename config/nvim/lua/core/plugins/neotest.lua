return {
	"nvim-neotest/neotest",
	cond = group.plugins.neotest,
	keys = {
		{ "<leader>nr", "<CMD>lua require('neotest').run.run()", desc = "run nearest test with neotest" },
	},
	opts = {},
}
