local map = require("core.utils.utils").map

require("markdown").setup({
	on_attach = function()
		map({ "n", "i" }, "<M-CR>", "<Cmd>MDListItemBelow<CR>")
	end,
})
