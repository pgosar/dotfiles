-- TODO: blocked - https://github.com/brenton-leighton/multiple-cursors.nvim/issues/65
return {
	"brenton-leighton/multiple-cursors.nvim",
	cond = group.plugins.multicursor,
	opts = {}, -- This causes the plugin setup function to be called
	event = "VeryLazy",
}
