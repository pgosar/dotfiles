return {
	"danymat/neogen",
	cond = group.plugins.neogen,
	keys = {
		{ "<leader>fd", "<CMD>Neogen<CR>", desc = "generate doc comments" },
	},
	-- TODO: blocking: https://github.com/danymat/neogen/issues/179
	opts = {
		-- snippet_engine = "nvim",
		placeholders_hl = "None",
	},
}
