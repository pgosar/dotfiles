return {
	"MeanderingProgrammer/markdown.nvim",
	cond = group.plugins.markdown_render,
	name = "render-markdown",
	ft = "markdown",
	config = function()
		require("render-markdown").setup({})
	end,
}
