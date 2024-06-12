return {
	"3rd/image.nvim",
	cond = group.plugins.image,
	dependencies = {
		{
			"vhyrro/luarocks.nvim",
			priority = 1001, -- this plugin needs to run before anything else
			opts = {
				rocks = { "magick" },
			},
		},
	},
	ft = "markdown",
	opts = {},
}
