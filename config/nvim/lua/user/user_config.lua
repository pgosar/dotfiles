-- use a user-config.lua file to provide your own configuration

local M = {}

-- add any null-ls sources you want here
M.setup_sources = function(b)
	return {
		b.formatting.clang_format,
		b.completion.luasnip,
		b.completion.tags,
		b.formatting.stylua,
		b.formatting.cbfmt,
		b.formatting.shfmt,
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
			},
		}),
		b.formatting.verible_verilog_format,
		b.diagnostics.verilator,
		b.diagnostics.checkmake,
		b.diagnostics.cmake_lint,
		b.diagnostics.pylint,
		b.diagnostics.revive,
		b.code_actions.gitrebase,
		b.code_actions.gitsigns,
		b.code_actions.gomodifytags,
		b.code_actions.refactoring,
		b.hover.dictionary,
	}
end

-- add mason sources to auto-install
M.mason_ensure_installed = {
	null_ls = {
		"cbfmt",
		"clangd",
		"codelldb",
		"css-lsp",
		"debugpy",
		"delve",
		"gofumpt",
		"goimports-reviser",
		"gopls",
		"html-lsp",
		"jq",
		"json-lsp",
		"lua-language-server",
		"prettierd",
		"basedpyright",
		"rust-analyzer",
		"shfmt",
		"stylua",
		"svlangserver",
		"typescript-language-server",
		"verible",
		"wgsl-analyzer",
	},
	dap = {
		"python",
	},
}

M.formatting_servers = {
	["rust_analyzer"] = { "rust" },
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

M.options = {
	opt = {
		conceallevel = 3,
		spell = true,
		spelllang = "en_us",
		spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
	},
}

M.enable_plugins = {
	aerial = true,
	alpha = true,
	asyncrun = true,
	autotag = true,
	autosave = true,
	bufferline = true,
	catppuccin = true,
	context = false,
	copilot = true,
	dressing = true,
	gitsigns = true,
	hop = true,
	img_clip = true,
	indent_blankline = true,
	lsp_zero = true,
	lualine = true,
	neodev = true,
	neoscroll = true,
	neotree = true,
	session_manager = true,
	noice = true,
	null_ls = true,
	autopairs = true,
	cmp = true,
	colorizer = true,
	dap = true,
	dap_python = true,
	dropbar = true,
	notify = true,
	markdown = true,
	surround = true,
	treesitter = true,
	ufo = true,
	onedark = true,
	project = true,
	rainbow = true,
	rust_tools = true,
	scope = true,
	telescope = true,
	toggleterm = true,
	trouble = true,
	twilight = true,
	whichkey = true,
	windline = false,
	zen = true,
}

M.plugins = {
	{
		"simrat39/rust-tools.nvim",
		ft = "rust",
		cond = M.enable_plugins.rust_tools,
		config = function()
			require("user.plugin-configs.rust-tools")
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		cond = M.enable_plugins.dap_python and M.enable_plugins.dap,
		config = function()
			require("user.plugin-configs.dap-python")
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		cond = M.enable_plugins.cmp and M.enable_plugins.copilot,
		event = "InsertEnter",
		dependencies = {
			"zbirenbaum/copilot-cmp",
			config = function()
				require("copilot_cmp").setup()
			end,
		},
		config = function()
			require("user.plugin-configs.copilot")
		end,
	},
	{
		"okuuva/auto-save.nvim",
		event = "VeryLazy",
		cond = M.enable_plugins.autosave,
		config = function()
			require("user.plugin-configs.autosave")
		end,
	},
	{
		"skywind3000/asyncrun.vim",
		event = "VeryLazy",
		cond = M.enable_plugins.asyncrun,
	},
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		cond = M.enable_plugins.markdown,
		config = function()
			require("user.plugin-configs.markdown")
		end,
	},
	{
		"catppuccin/nvim",
		lazy = false,
		cond = M.enable_plugins.catppuccin,
		config = function()
			require("user.plugin-configs.catppuccin")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		cond = M.enable_plugins.lualine,
		config = function()
			require("user.plugin-configs.lualine")
		end,
	},
	{
		"Bekaboo/dropbar.nvim",
		event = "VeryLazy",
		cond = M.enable_plugins.dropbar,
	},
}

M.autocommands = {
	alpha_folding = true,
	treesitter_folds = true,
	trailing_whitespace = true,
	remember_file_state = true,
	session_saved_notification = true,
	css_colorizer = true,
	cmp = true,
	term_spelling = true,
}

M.user_conf = function()
	require("user.init")
end

return M
