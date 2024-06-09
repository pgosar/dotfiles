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
			map("n", "J", "<C-v>j<CMD>VBox<CR>")
			map("n", "K", "<C-v>k<CMD>VBox<CR>")
			map("n", "L", "<C-v>l<CMD>VBox<CR>")
			map("n", "H", "<C-v>h<CMD>VBox<CR>")
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

	map("n", "<leader>v", ":lua Toggle_venn()<CR>")
end

-- Bufferline
if group.plugins.bufferline then
	map("n", "gb", "<CMD>BufferLinePick<CR>", { desc = "pick buffer" })
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
				end, { buffer = true })
			end
		end,
	})
end

-- Neogen
if group.plugins.neogen then
	map("n", "<Leader>fd", "<CMD>Neogen<CR>", { desc = "Generate Docs" })
end

-- Obsidian
if group.plugins.obsidian then
	map("n", "<leader>p", "<CMD>ObsidianPasteImg<CR>", { desc = "Paste clipboard image" })
	map("v", "<leader>ol", "<CMD>ObsidianLink<CR>")
	map("v", "<leader>oln", "<CMD>ObsidianLinkNew<CR>")
	map("n", "<leader>on", "<CMD>ObsidianNew<CR>")
	map("n", "<C-CR>", "<CMD>ObsidianFollowLink<CR>")
end

-- Multicursor
if group.plugins.multicursor then
	-- TODO remove if issue gets addressed (see plugins todo)
	-- vim.g.VM_default_mappings = false
	-- vim.g.VM_maps = {
	-- 	["Add Cursor Above"] = "<A-k>",
	-- 	["Add Cursor Down"] = "<A-j>",
	-- }
	map("n", "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>")
	map("n", "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>")
end

-- Dropbar
if group.plugins.dropbar then
	map("n", "<C-p>", "<CMD>lua require('dropbar.api').pick()<CR>")
end

-- Markdown
if group.plugins.markdown then
	map({ "n", "i" }, "<M-CR>", "<Cmd>MDListItemBelow<CR>")
end

-- DAP
if group.plugins.dap then
	_G.dap = require("dap")
	map("n", "<leader>dc", "<CMD>lua dap.continue()<CR>")
	map("n", "<leader>dn", "<CMD>lua dap.step_over()<CR>")
	map("n", "<leader>di", "<CMD>lua dap.step_into()<CR>")
	map("n", "<leader>do", "<CMD>lua dap.step_out()<CR>")
	map("n", "<leader>db", "<CMD>lua dap.toggle_breakpoint()<CR>")
	map("n", "<leader>dq", "<CMD>lua dap.disconnect({ terminateDebuggee = true })<CR>")
end

-- Trouble
if group.plugins.trouble then
	map("n", "<leader>tf", "<CMD>Trouble toggle diagnostics<CR>")
	map("n", "<leader>tt", "<CMD>Trouble toggle todo<CR>")
	map("n", "<leader>ts", "<CMD>Trouble toggle symbols<CR>")
	map("n", "<leader>tl", "<CMD>Trouble toggle lsp<CR>")
end

-- UFO
if group.plugins.ufo then
	map("n", "zR", "<CMD>lua require('ufo').openAllFolds()<CR>")
	map("n", "zM", "<CMD>lua require('ufo').closeAllFolds()<CR>")
end

-- ZenMode
if group.plugins.zen then
	map("n", "<leader>zm", "<CMD>ZenMode<CR>")
end

-- NeoTree
if group.plugins.neotree then
	map("n", "<leader>nt", "<CMD>Neotree float reveal toggle<CR>")
end

-- Searching and Highlighting
map("n", "m", "<CMD>noh<CR>")

-- Movement
-- in insert mode, type <c-d> and your cursor will move past the next separator
-- such as quotes, parens, brackets, etc.
map(
	"i",
	"<C-d>",
	"<CMD>set shortmess+=S<CR><left><c-o>/[\"';)>}\\]]<cr><c-o><CMD>noh<CR><CMD>set shortmess-=S<CR><right>"
)
map("i", "<C-b>", "<C-o>0")
map("i", "<C-a>", "<C-o>A")

-- Window switching from terminal
map("t", "<C-w>h", "<C-\\><C-n><C-w>h")
map("t", "<C-w>j", "<C-\\><C-n><C-w>j")
map("t", "<C-w>k", "<C-\\><C-n><C-w>k")
map("t", "<C-w>l", "<C-\\><C-n><C-w>l")

-- Window resizing
-- +/- keys with shift modifier
map("n", "-", ":resize +2<CR>")
map("n", "=", ":resize -2<CR>")
map("n", "_", ":vertical resize -2<CR>")
map("n", "+", ":vertical resize +2<CR>")

-- Command mode
map("c", "<C-p>", "<Up>")
map("c", "<C-n>", "<Down>")

-- Telescope
if group.plugins.telescope then
	map("n", "<leader>ff", "<CMD>Telescope find_files hidden=true<CR>", { desc = "Telescope Find Files" })
	map("n", "<leader>fg", "<CMD>Telescope live_grep<CR>")
	map("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
	map("n", "<leader>fp", "<CMD>Telescope projects<CR>")
	map({ "n", "x" }, "<leader>fr", function()
		require("telescope").extensions.refactoring.refactors()
	end)
end

-- Notify
if group.plugins.notify then
	map("n", "<ESC>", "<CMD>lua require('notify').dismiss()<CR>")
	map("i", "<ESC>", "<CMD>lua require('notify').dismiss()<CR><ESC>")
end

-- More LSP stuff
if group.plugins.lsp_zero then
	_G.buf = vim.lsp.buf
	-- lsp agnostic global rename
	map("n", "rg", ":%s/<C-r><C-w>//g<Left><Left>", { desc = "global substitution" })
	map("n", "gD", "<CMD>lua buf.declaration()<CR>")
	map("n", "gd", "<CMD>lua buf.definition()<CR>")
	map("n", "gi", "<CMD>lua buf.implementation()<CR>")
	map("i", "<C-k>", "<CMD>lua buf.signature_help()<CR>")
	map("n", "<leader>rn", "<CMD>lua buf.rename()<CR>")
	map({ "n", "v" }, "<leader>ca", "<CMD>lua buf.code_action()<CR>")
	map("n", "<C-h>", "<CMD>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>")
end

-- ToggleTerm
if group.plugins.toggleterm then
	local git_root = "cd $(git rev-parse --show-toplevel 2>/dev/null) && clear"
	map("t", "<C-\\>", "<C-\\><C-n>")
	-- opens terminal as a new tab at the git root
	-- as a regular window
	map("n", "<C-\\>", "<CMD>ToggleTerm go_back=0 cmd='" .. git_root .. "'<CR>", { desc = "new terminal" })
	map(
		"n",
		"<leader>tk",
		"<CMD>TermExec go_back=0 direction=float cmd='" .. git_root .. "&& tokei'<CR>",
		{ desc = "tokei" }
	)
	map("n", "<leader>gg", "<CMD>lua term.lazygit_toggle()<CR>", { desc = "open lazygit" })
	map("n", "<leader>gd", "<CMD>lua term.gdu_toggle()<CR>", { desc = "open gdu" })
	map("n", "<leader>bt", "<CMD>lua term.bashtop_toggle()<CR>", { desc = "open bashtop" })
end

-- Hop
if group.plugins.hop then
	map("n", "<leader>j", "<CMD>HopWord<CR>")
end

-- Gitsigns

-- making this a function here because all it does is create keybinds for gitsigns but
-- it needs to be attached to an on_attach function.
if group.plugins.gitsigns then
	M.gitsigns = function()
		local gs = package.loaded.gitsigns
		map("n", "]h", function()
			gs.nav_hunk("next")
		end, { desc = "next hunk" })
		map("n", "[h", function()
			gs.nav_hunk("prev")
		end, { desc = "prev hunk" })
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
