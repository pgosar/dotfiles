return {
	"folke/lazydev.nvim",
	cond = group.plugins.lazydev,
	ft = "lua",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "snacks.nvim",        words = { "Snacks" } },
		},
	},
}
