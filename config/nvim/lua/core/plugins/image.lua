return {
	"3rd/image.nvim",
	cond = group.plugins.image,
	ft = "markdown",
	opts = {},
	dependencies = {
		"vhyrro/luarocks.nvim",
		priority = 1001,
		opts = { rocks = { "magick" } },
	},
}
