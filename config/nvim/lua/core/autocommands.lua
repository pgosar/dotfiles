local augroup = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd

-- Removes any trailing white space when saving a file
if group.autocommands.trailing_whitespace then
	cmd({ "BufWritePre" }, {
		desc = "remove trailing whitespace on save",
		group = augroup("remove trailing whitespace", { clear = true }),
		pattern = { "*" },
		command = [[%s/\s\+$//e]],
	})
end

-- remembers file state, such as cursor position and any folds
if group.autocommands.remember_file_state then
	augroup("remember file state", { clear = true })
	cmd({ "BufWinLeave" }, {
		desc = "remember file state",
		group = "remember file state",
		pattern = { "*.*" },
		command = "mkview",
	})
	cmd({ "BufWinEnter" }, {
		desc = "remember file state",
		group = "remember file state",
		pattern = { "*.*" },
		command = "silent! loadview",
	})
end

-- no spellcheck in terminal buffers
if group.autocommands.term_spelling then
	cmd({ "TermOpen" }, {
		desc = "disable spellcheck in terminal buffers",
		group = augroup("disable_spell", { clear = true }),
		pattern = "*",
		command = "setlocal nospell",
	})
end

-- set relative number in normal mode
if group.autocommands.number then
	cmd({ "VimEnter", "InsertLeave" }, {
		desc = "set relativenumber",
		group = augroup("set_relativenumber", { clear = true }),
		pattern = "*",
		command = "set relativenumber",
	})
	cmd({ "InsertEnter" }, {
		desc = "set number",
		group = augroup("set_number", { clear = true }),
		pattern = "*",
		command = "set number norelativenumber",
	})
end

-- disable creating new comment on next line on enter
if group.autocommands.comment then
	cmd({ "Filetype" }, {
		desc = "disable autocomment next line on enter",
		group = augroup("disable_autocomment_next_line", { clear = true }),
		pattern = "*",
		command = "setlocal formatoptions-=r",
	})
end

-- synchronize terminal background with neovim
if group.autocommands.syncbackground then
	cmd({ "UIEnter", "ColorScheme" }, {
		desc = "sync terminal background with neovim",
		group = augroup("sync_background", { clear = true }),
		pattern = "*",
		callback = function()
			local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
			if not normal.bg then
				return
			end
			io.write(string.format("\027]11;#%06x\027\\", normal.bg))
		end,
	})

	cmd("UILeave", {
		desc = "reset background",
		group = augroup("reset_background", { clear = true }),
		pattern = "*",
		callback = function()
			io.write("\027]111\027\\")
		end,
	})
end

-- Sets cwd to git root
if group.autocommands.autoroot then
	cmd("BufEnter", {
		group = augroup("auto_root", { clear = true }),
		callback = require("core.utils.utils").set_root,
	})
end
