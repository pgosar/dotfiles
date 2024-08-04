local vim_opts = require("core.utils.utils").vim_opts
vim.opt.shortmess:append("sIW")

vim_opts({
	opt = {
		autowrite = true, -- Auto save before commands
		clipboard = "unnamedplus", -- Use system clipboard
		conceallevel = 3, -- Hide concealed text
		confirm = true, -- Confirm save changes
		cursorline = true, -- Highlight cursor line
		cursorlineopt = "number", -- Highlight cursor line number
		expandtab = true, -- Use spaces instead of tabs
		foldenable = true, -- Enable folding
		foldexpr = "nvim_treesitter#foldexpr()", -- Treesitter folding
		foldlevel = 99, -- Set fold level
		foldlevelstart = 99, -- Start with all folds open
		foldmethod = "expr", -- Fold based on expression
		foldopen = "jump,block,hor,mark,percent,quickfix,search,tag,undo", -- Commands that open folds
		guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20", -- Cursor settings
		hidden = true, -- Allow buffer switching without saving
		ignorecase = true, -- Ignore case in search
		laststatus = 3, -- Global statusline
		linebreak = true, -- Break lines at word boundaries
		number = true, -- Show line numbers
		numberwidth = 6, -- Width of number column
		pumheight = 10, -- Auto-complete menu max height
		scrolloff = 5, -- Lines above/below cursor
		sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions", -- Session options
		shiftwidth = 2, -- Spaces per indent
		showbreak = "=>>", -- Wrapped line prefix
		breakindent = true,
		showmode = false, -- Hide mode in command line
		smartcase = true, -- Smart case search
		softtabstop = 2, -- Spaces per <Tab>
		spell = true, -- Enable spell check
		spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add", -- Custom spell file
		spelllang = "en_us", -- Spell check language
		tabstop = 2, -- Spaces per tab
		termguicolors = true, -- 24-bit RGB colors
		textwidth = 100, -- Max text width
		undofile = true, -- Persistent undo
		updatetime = 100, -- Faster completion
	},
	g = {
		mapleader = " ",
		rust_recommended_style = false,
	},
})
