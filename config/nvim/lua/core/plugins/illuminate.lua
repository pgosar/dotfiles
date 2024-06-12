return {
	"RRethy/vim-illuminate",
	cond = group.plugins.illuminate,
	event = "VeryLazy",
	config = function()
		require("illuminate").configure()
	end,
}
