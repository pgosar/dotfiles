return {
	"smoka7/hop.nvim",
	cond = group.plugins.hop,
	cmd = "HopWord",
	keys = {
		{ "<leader>j", "<CMD>HopWord<CR>", desc = "hop across file" },
	},
	opts = { multi_windows = true },
}
