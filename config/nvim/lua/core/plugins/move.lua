return {
	"echasnovski/mini.move",
	cond = group.plugins.move,
	event = "VeryLazy",
	config = function()
		require("mini.move").setup()
	end,
}
