return {
	"danymat/neogen",
	cond = group.plugins.neogen,
	keys = {
		{
			"<leader>fd",
			function()
				require("neogen").generate()
			end,
			desc = "generate doc comments",
		},
	},
	opts = { placeholders_hl = nil },
}
