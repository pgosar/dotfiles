return {
	"OXY2DEV/markview.nvim",
	cond = group.plugins.markview,
	ft = "markdown",
	keys = {
		{ "<leader>mm", "<CMD>Markview toggle<CR>", desc = "Toggle markdown viewer" },
	},
	opts = {
		modes = { "n", "i", "no", "c" },
		hybrid_modes = { "i" },

		callbacks = {
			on_enable = function(_, win)
				vim.wo[win].conceallevel = 2
				vim.wo[win].concealcursor = "nc"
			end,
		},
		filetypes = { "markdown", "quarto", "rmd", "tex" },
		html = { tags = { default = { conceal = true } } },
	},
}
