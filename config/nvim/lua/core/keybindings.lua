local map = require("core.utils.utils").map

map("n", "<leader>l", "<CMD>Lazy<CR>", { desc = "open Lazy UI" })

-- Searching and Highlighting
map("n", "m", "<CMD>noh<CR>", { desc = "clear search highlight" })

-- Movement
-- in insert mode, type <c-d> and your cursor will move past the next separator
-- such as quotes, parens, brackets, etc.
map(
	"i",
	"<C-d>",
	"<CMD>set shortmess+=S<CR><left><c-o>/[\"';)>{}\\]]<cr><c-o><CMD>noh<CR><CMD>set shortmess-=S<CR><right>",
	{ desc = "move past separator" }
)
map("i", "<C-b>", "<C-o>0", { desc = "move to beginning of line" })
map("i", "<C-a>", "<C-o>A", { desc = "move to end of line" })

-- Window switching from terminal
map("t", "<C-w>h", "<C-\\><C-n><C-w>h", { desc = "move to left window from terminal" })
map("t", "<C-w>j", "<C-\\><C-n><C-w>j", { desc = "move to bottom window from terminal" })
map("t", "<C-w>k", "<C-\\><C-n><C-w>k", { desc = "move to top window from terminal" })
map("t", "<C-w>l", "<C-\\><C-n><C-w>l", { desc = "move to right window from terminal" })

-- Switching buffers
map("n", "<leader>bn", "<CMD>bnext<CR>", { desc = "switch to next buffer" })
map("n", "<leader>bp", "<CMD>bprevious<CR>", { desc = "switch to prev buffer" })

-- Switching tabs
map("n", "<leader>to", "<CMD>tabnew<CR>", { desc = "create new tab" })
map("n", "<leader>tn", "<CMD>tabnext<CR>", { desc = "switch to next tab" })
map("n", "<leader>tp", "<CMD>tabprevious<CR>", { desc = "switch to prev tab" })

-- Window resizing
-- +/- keys with shift modifier
map("n", "-", ":resize +2<CR>", { desc = "resize window down" })
map("n", "=", ":resize -2<CR>", { desc = "resize window up" })
map("n", "_", ":vertical resize -2<CR>", { desc = "resize window left" })
map("n", "+", ":vertical resize +2<CR>", { desc = "resize window right" })

-- cut without yanking, since v/V with x is also cut
map("n", "X", "D", { desc = "cut and yank" })
map({ "n", "v" }, "d", '"_d', { desc = "cut without yanking" })

map(
	"i",
	"<C-c>",
	function() require("core.utils.utils").close_floating_windows() end,
	{ desc = "close all floating windows when in insert mode" }
)
