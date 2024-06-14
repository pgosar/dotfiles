return {
	"jbyuki/venn.nvim",
	cond = group.plugins.venn,
	keys = {
		{ "<leader>v", ":lua Toggle_venn()<CR>", desc = "toggle venn" },
	},
	init = function()
		function _G.Toggle_venn()
			local venn_enabled = vim.inspect(vim.b.venn_enabled)
			local map = require("core.utils.utils").map
			if venn_enabled == "nil" then
				vim.b.venn_enabled = true
				vim.notify("Venn enabled", "info", { title = "Venn" })
				vim.cmd([[setlocal ve=all]])
				-- draw a line on HJKL keystokes
				-- does not work with <CMD>
				map("n", "J", "<C-v>j:VBox<CR>", { desc = "draw arrow down", buffer = true })
				map("n", "K", "<C-v>k:VBox<CR>", { desc = "draw arrow up", buffer = true })
				map("n", "L", "<C-v>l:VBox<CR>", { desc = "draw arrow right", buffer = true })
				map("n", "H", "<C-v>h:VBox<CR>", { desc = "draw arrow left", buffer = true })
				-- draw a box by pressing "f" with visual selection
				map("v", "f", ":VBox<CR>", { desc = "draw box", buffer = true })
			else
				vim.notify("Venn disabled", "info", { title = "Venn" })
				vim.cmd([[setlocal ve=]])
				vim.keymap.del("n", "J")
				vim.keymap.del("n", "K")
				vim.keymap.del("n", "L")
				vim.keymap.del("n", "H")
				vim.keymap.del("v", "f")
				vim.b.venn_enabled = nil
			end
		end
	end,
}
