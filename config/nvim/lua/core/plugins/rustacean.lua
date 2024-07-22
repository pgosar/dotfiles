return {
	"mrcjkb/rustaceanvim",
	cond = group.plugins.rustacean,
	init = function()
		vim.cmd([[let g:rust_recommended_style = 0]])
	end,
	ft = "rust",
}
