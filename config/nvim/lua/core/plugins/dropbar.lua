return {
	"Bekaboo/dropbar.nvim",
  -- stylua: ignore
	keys = {
		{ "<C-p>", function() require("dropbar.api").pick() end, { desc = "pick from dropbar" }, },
	},
	lazy = false,
	cond = group.plugins.dropbar,
}