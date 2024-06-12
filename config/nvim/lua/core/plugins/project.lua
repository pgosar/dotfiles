return {
	"ahmedkhalf/project.nvim",
	cond = group.plugins.project,
	event = "VeryLazy",
	config = function()
		require("project_nvim").setup()
	end,
}
