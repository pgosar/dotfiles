local map = require("core.utils.utils").map
local ok, defaults = pcall(require, "defaults")
if not ok then
	vim.api.nvim_err_writeln("Failed to load defaults.lua")
end
local group = defaults.group

local M = {}

if group.plugins.venn then
	function _G.Toggle_venn()
		local venn_enabled = vim.inspect(vim.b.venn_enabled)
		if venn_enabled == "nil" then
			vim.b.venn_enabled = true
			vim.notify("Venn enabled", "info", { title = "Venn" })
			vim.cmd([[setlocal ve=all]])
			-- draw a line on HJKL keystokes
			map("n", "J", "<C-v>j<CMD>VBox<CR>", { desc = "draw arrow down" })
			map("n", "K", "<C-v>k<CMD>VBox<CR>", { desc = "draw arrow up" })
			map("n", "L", "<C-v>l<CMD>VBox<CR>", { desc = "draw arrow right" })
			map("n", "H", "<C-v>h<CMD>VBox<CR>", { desc = "draw arrow left" })
			-- draw a box by pressing "f" with visual selection
			map("v", "f", "<CMD>VBox<CR>")
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

	map("n", "<leader>v", ":lua Toggle_venn()<CR>", { desc = "toggle venn" })
end

-- Bufferline
if group.plugins.bufferline then
	map("n", "gb", "<CMD>BufferLinePick<CR>", { desc = "pick buffer to open" })
end

-- Nabla
-- for some reason vim.bo.filetype is not available in time
if group.plugins.nabla then
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*.md",
		callback = function()
			if vim.bo.filetype == "markdown" then
				map("n", "K", function()
					require("nabla").popup()
				end, { buffer = true, desc = "toggle nabla latex viewer popup" })
			end
		end,
	})
end

-- Neogen
if group.plugins.neogen then
	map("n", "<Leader>fd", "<CMD>Neogen<CR>", { desc = "Generate documentation comments" })
end

-- Obsidian
if group.plugins.obsidian then
	map("n", "<leader>p", "<CMD>ObsidianPasteImg<CR>", { desc = "Paste clipboard image" })
	map("v", "<leader>ol", "<CMD>ObsidianLink<CR>", { desc = "link current word to file in obsidian" })
	map("v", "<leader>oln", "<CMD>ObsidianLinkNew<CR>", { desc = "link current word to new file in obsidian" })
	map("n", "<leader>on", "<CMD>ObsidianNew<CR>", { desc = "new file in obsidian" })
	map("n", "<C-CR>", "<CMD>ObsidianFollowLink<CR>", { desc = "follow link in obsidian" })
end

-- Multicursor
if group.plugins.multicursor then
	-- TODO remove if issue gets addressed (see plugins todo)
	-- vim.g.VM_default_mappings = false
	-- vim.g.VM_maps = {
	-- 	["Add Cursor Above"] = "<A-k>",
	-- 	["Add Cursor Down"] = "<A-j>",
	-- }
	map("n", "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", { desc = "add multi cursor down" })
	map("n", "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", { desc = "add multi cursor up" })
end

-- Dropbar
if group.plugins.dropbar then
	map("n", "<C-p>", function()
		require("dropbar.api").pick()
	end, { desc = "pick from dropbar" })
end

-- Markdown
if group.plugins.markdown then
	map({ "n", "i" }, "<M-CR>", "<Cmd>MDListItemBelow<CR>", { desc = "insert new markdown list item below" })
end

-- DAP
if group.plugins.dap then
	local dap = require("dap")
	map("n", "<leader>dc", function()
		dap.continue()
	end, { desc = "debugger continue" })
	map("n", "<leader>dn", function()
		dap.step_over()
	end, { desc = "debugger step over" })
	map("n", "<leader>di", function()
		dap.step_into()
	end, { desc = "debugger step into" })
	map("n", "<leader>do", function()
		dap.step_out()
	end, { desc = "debugger step out" })
	map("n", "<leader>db", function()
		dap.toggle_breakpoint()
	end, { desc = "toggle breakpoint" })
	map("n", "<leader>dq", function()
		dap.disconnect({ terminateDebuggee = true })
	end, { desc = "disconnect debugger" })
end

-- Trouble
if group.plugins.trouble then
	map("n", "<leader>tf", "<CMD>Trouble toggle diagnostics<CR>", { desc = "Trouble toggle diagnostics" })
	map("n", "<leader>tt", "<CMD>Trouble toggle todo<CR>", { desc = "Trouble toggle todo" })
	map("n", "<leader>ts", "<CMD>Trouble toggle symbols<CR>", { desc = "Trouble toggle symbols" })
	map("n", "<leader>tl", "<CMD>Trouble toggle lsp<CR>", { desc = "Trouble toggle lsp" })
end

-- UFO
if group.plugins.ufo then
	local ufo = require("ufo")
	map("n", "zR", function()
		ufo.openAllFolds()
	end, { desc = "open all ufo folds" })
	map("n", "zM", function()
		ufo.closeAllFolds()
	end, { desc = "close all ufo folds" })
end

-- ZenMode
if group.plugins.zen then
	map("n", "<leader>zm", "<CMD>ZenMode<CR>", { desc = "toggle zen mode" })
end

-- NeoTree
if group.plugins.neotree then
	map("n", "<leader>nt", "<CMD>Neotree float reveal toggle<CR>", { desc = "toggle neotree" })
end

-- Searching and Highlighting
map("n", "m", "<CMD>noh<CR>", { desc = "clear search highlight" })

-- Movement
-- in insert mode, type <c-d> and your cursor will move past the next separator
-- such as quotes, parens, brackets, etc.
map(
	"i",
	"<C-d>",
	"<CMD>set shortmess+=S<CR><left><c-o>/[\"';)>}\\]]<cr><c-o><CMD>noh<CR><CMD>set shortmess-=S<CR><right>",
	{ desc = "move past separator" }
)
map("i", "<C-b>", "<C-o>0", { desc = "move to beginning of line" })
map("i", "<C-a>", "<C-o>A", { desc = "move to end of line" })

-- Window switching from terminal
map("t", "<C-w>h", "<C-\\><C-n><C-w>h", { desc = "move to left window from terminal" })
map("t", "<C-w>j", "<C-\\><C-n><C-w>j", { desc = "move to bottom window from terminal" })
map("t", "<C-w>k", "<C-\\><C-n><C-w>k", { desc = "move to top window from terminal" })
map("t", "<C-w>l", "<C-\\><C-n><C-w>l", { desc = "move to right window from terminal" })

-- Window resizing
-- +/- keys with shift modifier
map("n", "-", ":resize +2<CR>", { desc = "resize window down" })
map("n", "=", ":resize -2<CR>", { desc = "resize window up" })
map("n", "_", ":vertical resize -2<CR>", { desc = "resize window left" })
map("n", "+", ":vertical resize +2<CR>", { desc = "resize window right" })

-- Command mode
map("c", "<C-p>", "<Up>", { desc = "browse command history up" })
map("c", "<C-n>", "<Down>", { desc = "browse command history down" })

-- Telescope
if group.plugins.telescope then
	map("n", "<leader>ff", "<CMD>Telescope find_files hidden=true<CR>", { desc = "find files in telescope" })
	map("n", "<leader>fg", "<CMD>Telescope live_grep<CR>", { desc = "grep in telescope" })
	map("n", "<leader>fb", "<CMD>Telescope buffers<CR>", { desc = "search available buffers in telescope" })
	map("n", "<leader>fp", "<CMD>Telescope projects<CR>", { desc = "search available projects in telescope" })
	map({ "n", "x" }, "<leader>fr", function()
		require("telescope").extensions.refactoring.refactors()
	end, { desc = "refactor in telescope" })
end

-- Notify
if group.plugins.notify then
	local notify = require("notify")
	map("n", "<ESC>", function()
		notify.dismiss({})
	end, { desc = "dismiss notifications" })
	map("i", "<ESC>", function()
		notify.dismiss({})
		vim.cmd("stopinsert")
	end, { desc = "dismiss notifications" })
end

-- More LSP stuff
if group.plugins.lsp_zero then
	_G.buf = vim.lsp.buf
	-- lsp agnostic global rename
	map("n", "rg", ":%s/<C-r><C-w>//g<Left><Left>", { desc = "global substitution" })
	map("n", "gD", function()
		buf.declaration()
	end, { desc = "go to declaration" })
	map("n", "gd", function()
		buf.definition()
	end, { desc = "go to definition" })
	map("n", "gi", function()
		buf.implementation()
	end, { desc = "go to implementation" })
	map("i", "<C-k>", function()
		buf.signature_help()
	end, { desc = "signature help" })
	map("n", "<leader>rn", function()
		buf.rename()
	end, { desc = "rename symbol" })
	map({ "n", "v" }, "<leader>ca", function()
		buf.code_action()
	end, { desc = "code action" })
	map("n", "<C-h>", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
	end, { desc = "toggle inlay hints" })
end

-- ToggleTerm
if group.plugins.toggleterm then
	local git_root = "cd $(git rev-parse --show-toplevel 2>/dev/null) && clear"
	map("t", "<C-\\>", "<C-\\><C-n>", { desc = "toggle terminal" })
	-- opens terminal as a new tab at the git root
	-- as a regular window
	map("n", "<C-\\>", "<CMD>ToggleTerm go_back=0 cmd='" .. git_root .. "'<CR>", { desc = "toggle terminal" })
	map(
		"n",
		"<leader>tk",
		"<CMD>TermExec go_back=0 direction=float cmd='" .. git_root .. "&& tokei'<CR>",
		{ desc = "open tokei" }
	)
	map("n", "<leader>gg", function()
		term.lazygit_toggle()
	end, { desc = "open lazygit" })
	map("n", "<leader>gd", function()
		term.gdu_toggle()
	end, { desc = "open gdu" })
	map("n", "<leader>bt", function()
		term.bashtop_toggle()
	end, { desc = "open bashtop" })
end

-- Hop
if group.plugins.hop then
	map("n", "<leader>j", "<CMD>HopWord<CR>", { desc = "hop across file" })
end

-- Gitsigns

-- making this a function here because all it does is create keybinds for gitsigns but
-- it needs to be attached to an on_attach function.
if group.plugins.gitsigns then
	M.gitsigns = function()
		local gs = package.loaded.gitsigns
		map("n", "]h", function()
			gs.nav_hunk("next")
		end, { desc = "go to next hunk" })
		map("n", "[h", function()
			gs.nav_hunk("prev")
		end, { desc = "go to prev hunk" })
		map("n", "<leader>hs", gs.stage_hunk, { desc = "stage hunk" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "reset hunk" })
		map("n", "<leader>hS", gs.stage_buffer, { desc = "stage buffer" })
		map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
		map("n", "<leader>hR", gs.reset_buffer, { desc = "reset buffer" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "preview hunk" })
		map("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, { desc = "complete blame line history" })
		map("n", "<leader>lb", gs.toggle_current_line_blame, { desc = "toggle blame line" })
		-- diff at current working directory
		map("n", "<leader>hd", gs.diffthis, { desc = "diff at cwd" })
		-- diff at root of git repository
		map("n", "<leader>hD", function()
			gs.diffthis("~")
		end, { desc = "diff at root of git repo" })
		map("n", "<leader>td", gs.toggle_deleted, { desc = "toggle deleted line" })
	end
end

-- cmp (these are defined in cmp's configuration file)
-- ["<C-c>"] = cmp.mapping.abort(),
return M
