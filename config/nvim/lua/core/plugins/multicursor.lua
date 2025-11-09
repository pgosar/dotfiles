-- TODO: blocked - https://github.com/brenton-leighton/multiple-cursors.nvim/issues/65
-- Vim plugin!

return {
	"mg979/vim-visual-multi",
	keys = {
		{ "<C-k>", "<Plug>(VM-Add-Cursor-Up)",   desc = "add multi cursor up" },
		{ "<C-j>", "<Plug>(VM-Add-Cursor-Down)", desc = "add multi cursor down" },
	},
	init = function()
		vim.g.VM_default_mappings = false
	end,
}
