return {
	"folke/flash.nvim",
	cond = group.plugins.flash,
  -- stylua: ignore
  keys = {
    -- make sure it's activated when searching
    {"/", "/"},
    {"?", "?"},
    { "<leader>j", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "<leader>J", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" }, },
	opts = {
		modes = {
			search = { enabled = true },
			char = { jump_labels = true },
		},
	},
}
