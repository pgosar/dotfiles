local M = {}

-- Null-ls sources list
M.setup_sources = function(b)
	return {
		b.formatting.clang_format,
		b.formatting.stylua,
		b.formatting.cbfmt,
		b.formatting.shfmt.with({
			filetypes = {
				"sh",
				"bash",
				"zsh",
			},
		}),
		b.formatting.gofumpt,
		b.formatting.black,
		b.formatting.cmake_format,
		b.formatting.prettierd.with({
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"html",
				"css",
				"json",
				"yaml",
				"yml",
			},
		}),
		b.formatting.verible_verilog_format,
		b.diagnostics.verilator,
		b.diagnostics.checkmake,
		b.diagnostics.cmake_lint,
		b.diagnostics.pylint,
		b.diagnostics.revive,
		b.code_actions.gitsigns,
		b.code_actions.gomodifytags,
		b.code_actions.refactoring,
	}
end

-- Auto install sources
M.ensure_installed = {
	treesitter = {
		"asm",
		"bash",
		"c",
		"cmake",
		"comment",
		"cpp",
		"css",
		"csv",
		"cuda",
		"diff",
		"disassembly",
		"dockerfile",
		"xml",
		"gitattributes",
		"gitcommit",
		"gitignore",
		"glsl",
		"go",
		"gomod",
		"gosum",
		"html",
		"java",
		"javascript",
		"jsdoc",
		"json",
		"json5",
		"jsonc",
		"latex",
		"lua",
		"luap",
		"luau",
		"make",
		"markdown",
		"meson",
		"ninja",
		"objdump",
		"printf",
		"python",
		"regex",
		"ron",
		"rust",
		"scss",
		"toml",
		"tsx",
		"verilog",
		"wgsl",
		"yaml",
	},
	null_ls = {
		"rust_analyzer",
		"bash-language-server",
		"cbfmt",
		"clangd",
		"css-lsp",
		"debugpy",
		"delve",
		"gofumpt",
		"goimports_reviser",
		"gopls",
		"html_lsp",
		"jq",
		"json_lsp",
		"lua_language_server",
		"prettierd",
		"basedpyright",
		"shfmt",
		"stylua",
		"svlangserver",
		"typescript_language_server",
		"verible",
		"wgsl_analyzer",
		"mdformat",
		"zls",
	},
	dap = {
		"python",
		"codelldb",
	},
}

M.settings = { bigfile_enable = true }

-- setup formatting servers
M.formatting_servers = {
	["rust_analyzer"] = { "rust" },
	["zls"] = { "zig" },
	["null-ls"] = {
		"lua",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"html",
		"css",
		"json",
		"python",
		"sh",
		"bash",
		"zsh",
		"go",
		"cpp",
		"c",
		"cmake",
		"systemverilog",
		"markdown",
	},
}

-- default value is true for all
M.group = {
	plugins = {
		ai = true,
		align = true,
		alpha = true,
		asyncrun = true,
		autotag = true,
		autosave = true,
		bufferline = true,
		catppuccin = true,
		blink = true,
		dap = true,
		dap_python = true,
		dressing = true,
		dropbar = true,
		flash = true,
		gitsigns = true,
		highlight_colors = true,
		illuminate = true,
		image = true,
		indent_blankline = true,
		lazydev = true,
		lualine = true,
		markdown = true,
		markview = true,
		move = true,
		multicursor = true,
		neogen = true,
		neoscroll = true,
		neotest = true,
		neotree = true,
		noice = true,
		none_ls = true,
		notify = true,
		obsidian = true,
		persistence = true,
		project = true,
		refactor = true,
		scrollbar = true,
		scope = true,
		surround = true,
		fzf = true,
		todo_comments = true,
		toggleterm = true,
		autopairs = true,
		rainbow = true,
		treesitter = true,
		trouble = true,
		ufo = true,
		venn = true,
		virt_column = true,
		whichkey = true,
		workspace_diagnostics = true,
		zen = true,
	},
	autocommands = {
		trailing_whitespace = true,
		remember_file_state = true,
		term_spelling = true,
		number = true,
		comment = true,
		syncbackground = true,
		autoroot = true,
		auto_format_on_autosave = true,
		term_line_numbers = true,
		autoformat = true,
	},
}

M.colors = {
	mocha_override = {
		base = "#252525",
		mantle = "#272727",
		crust = "#252525",
	},
	scrollbar = "#2f334d",
	terminal = "#222222",
}

M.colorscheme = "catppuccin"

_G.icons = {
	lualine = {
		lsp = " ",
	},
	comments = {
		fix = " ",
		todo = " ",
		hack = " ",
		warn = " ",
		perf = "󱑂 ",
		note = " ",
		test = "󰙨 ",
	},
	alpha = {
		new_file = " ",
		find = " ",
		recent = " ",
		last_session = " ",
		open_session = " ",
		open_project = " ",
	},
	dap = {
		breakpoint = " ",
		stopped = "󰁕 ",
	},
	diagnostics = {
		error = " ",
		warn = " ",
		hint = "󰌵",
		info = " ",
		debug = " ",
		trace = "✎",
	},
	git = {
		branch = "",
		added = " ",
		modified = " ",
		removed = " ",
		renamed = " ",
		untracked = "",
		ignored = " ",
		unstaged = "󰄱 ",
		staged = " ",
		conflict = "",
	},
	lsp = {
		error = "✘",
		warn = "▲",
		hint = "⚑",
		info = "»",
	},
}

M.dashboard_ascii = [[		⠀⠀
           ⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀  ⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⠀⠀⠀⢠⣾⣧⣤⡖⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠋⠀⠉⠀⢄⣸⣿⣿⣿⣿⣿⣥⡤⢶⣿⣦⣀⡀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡆⠀⠀⠀⣙⣛⣿⣿⣿⣿⡏⠀⠀⣀⣿⣿⣿⡟
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠷⣦⣤⣤⣬⣽⣿⣿⣿⣿⣿⣿⣿⣟⠛⠿⠋⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠋⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⡆⠀⠀
⠀⠀⠀⠀⣠⣶⣶⣶⣿⣦⡀⠘⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⠈⢹⡏⠁⠀⠀
⠀⠀⠀⢀⣿⡏⠉⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡆⠀⢀⣿⡇⠀⠀⠀
⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡘⣿⣿⣃⠀⠀⠀
⣴⣷⣀⣸⣿⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⠹⣿⣯⣤⣾⠏⠉⠉⠉⠙⠢⠀
⠈⠙⢿⣿⡟⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣄⠛⠉⢩⣷⣴⡆⠀⠀⠀⠀⠀
⠀⠀⠀⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣀⡠⠋⠈⢿⣇⠀⠀
⠀⠀⠀          ⠙⠿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]

return M
