-- NOTE: unnecessary right now, but neotest will be a good addition whenever I actually need it
-- or need something to do

local enabled = require("core.utils.utils").enabled

local exist, user_config = pcall(require, "user_config")
local group = exist and type(user_config) == "table" and user_config.enable_plugins or {}
require("lazy").setup({
	{
		"goolord/alpha-nvim",
		cond = enabled(group, "alpha"),
		lazy = false,
		config = function()
			require("plugin-configs.alpha")
		end,
	},
	{
		"skywind3000/asyncrun.vim",
		event = "VeryLazy",
		cond = enabled(group, "asyncrun"),
	},
	{
		"okuuva/auto-save.nvim",
		event = "VeryLazy",
		cond = enabled(group, "autosave"),
		config = function()
			require("plugin-configs.autosave")
		end,
	},
	{
		"akinsho/bufferline.nvim",
		cond = enabled(group, "bufferline"),
		lazy = false,
		config = function()
			require("plugin-configs.bufferline")
		end,
	},
	{
		"catppuccin/nvim",
		cond = enabled(group, "catppuccin"),
		config = function()
			require("plugin-configs.catppuccin")
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		cond = enabled(group, "cmp") and enabled(group, "copilot"),
		event = "InsertEnter",
		config = function()
			require("plugin-configs.copilot")
		end,
		dependencies = {
			"zbirenbaum/copilot-cmp",
			config = true,
		},
	},
	{
		"stevearc/dressing.nvim",
		cond = enabled(group, "dressing"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.dressing")
		end,
	},
	{
		"Bekaboo/dropbar.nvim",
		lazy = false, -- done by default
		cond = enabled(group, "dropbar"),
	},
	{
		"lewis6991/gitsigns.nvim",
		cond = enabled(group, "gitsigns"),
		event = "VimEnter",
		config = function()
			require("plugin-configs.gitsigns")
		end,
	},
	{
		"smoka7/hop.nvim",
		cond = enabled(group, "hop"),
		event = "VimEnter",
		config = function()
			require("plugin-configs.hop")
		end,
	},
	{
		"3rd/image.nvim",
		cond = enabled(group, "image"),
		dependencies = {
			{
				"vhyrro/luarocks.nvim",
				priority = 1001, -- this plugin needs to run before anything else
				opts = {
					rocks = { "magick" },
				},
			},
		},
		lazy = false,
		opts = {},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		cond = enabled(group, "indent_blankline"),
		event = "VimEnter",
		main = "ibl",
		config = true,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		cond = enabled(group, "lualine"),
		config = function()
			require("plugin-configs.lualine")
		end,
	},
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown",
		cond = enabled(group, "markdown"),
		opts = {},
	},
	{
		"MeanderingProgrammer/markdown.nvim",
		cond = enabled(group, "markdown_render"),
		name = "render-markdown",
		ft = "markdown",
		config = function()
			require("render-markdown").setup({})
		end,
	},
	{
		"echasnovski/mini.align",
		cond = enabled(group, "align"),
		event = "VeryLazy",
		config = true,
	},
	{
		"jbyuki/nabla.nvim",
		cond = enabled(group, "nabla"),
		ft = { "markdown" },
	},
	{
		"folke/lazydev.nvim",
		cond = enabled(group, "align"),
		ft = "lua",
		opts = {},
	},
	{
		"danymat/neogen",
		cond = enabled(group, "neogen"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neogen")
		end,
	},
	{
		"karb94/neoscroll.nvim",
		cond = enabled(group, "neoscroll"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neoscroll")
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		cond = enabled(group, "neotree"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.neo-tree")
		end,
		branch = "v3.x",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/noice.nvim",
		cond = enabled(group, "noice"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.noice")
		end,
		dependencies = { { "MunifTanjim/nui.nvim" } },
	},
	{
		"nvimtools/none-ls.nvim",
		cond = enabled(group, "null_ls"),
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugin-configs.null-ls")
		end,
		dependencies = {
			{
				"jay-babu/mason-null-ls.nvim",
				cmd = { "NullLsInstall", "NullLsUninstall" },
				config = function()
					require("plugin-configs.mason-null-ls")
				end,
			},
		},
	},
	{
		"windwp/nvim-autopairs",
		cond = enabled(group, "autopairs"),
		event = "InsertEnter",
		config = function()
			require("plugin-configs.autopairs")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		cond = enabled(group, "cmp"),
		event = { "InsertEnter", "CmdlineEnter" },
		config = function()
			require("plugin-configs.cmp")
		end,
		dependencies = {
			{ "onsails/lspkind.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-nvim-lua" },
			{
				"garymjr/nvim-snippets",
				opts = { friendly_snippets = true },
				dependencies = { { "rafamadriz/friendly-snippets" } },
			},
		},
	},
	{
		"NvChad/nvim-colorizer.lua",
		cond = enabled(group, "colorizer"),
		ft = { "css", "scss", "html", "xml", "svg", "js", "jsx", "ts", "tsx", "php", "vue" },
	},
	{
		"mfussenegger/nvim-dap",
		cond = enabled(group, "dap"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.dap")
		end,
		dependencies = {
			{
				"mfussenegger/nvim-dap-python",
				ft = "python",
				cond = enabled(group, "dap_python") and enabled(group, "dap"),
				config = function()
					require("plugin-configs.dap-python")
				end,
			},
			{
				"jay-babu/mason-nvim-dap.nvim",
				cmd = { "DapInstall", "DapUninstall" },
				config = function()
					require("plugin-configs.mason-nvim-dap")
				end,
			},
			{
				"rcarriga/nvim-dap-ui",
				config = true,
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				config = true,
			},
			{
				"nvim-neotest/nvim-nio",
			},
		},
	},
	-- plugin order is important for these 3 -------------
	{
		"VonHeikemen/lsp-zero.nvim",
		cond = enabled(group, "lsp_zero"),
		event = { "BufReadPre", "BufNewFile" },
		branch = "v3.x",
		dependencies = {},
	},
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = true,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		config = function()
			require("plugin-configs.lsp")
		end,
		dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
		},
	},
	------------------------------------------------------
	{
		"rcarriga/nvim-notify",
		cond = enabled(group, "notify"),
		lazy = false,
	},
	{
		"kylechui/nvim-surround",
		cond = enabled(group, "surround"),
		event = "VimEnter",
		config = true,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		cond = enabled(group, "treesitter"),
		build = ":TSUpdate",
		lazy = false,
		config = function()
			require("plugin-configs.treesitter")
		end,
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{ "HiPhish/rainbow-delimiters.nvim", cond = enabled(group, "rainbow") },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
		},
	},
	{
		"windwp/nvim-ts-autotag",
		cond = enabled(group, "autotag"),
		event = { "BufReadPre", "BufNewFile" },
		config = true,
	},
	{
		"kevinhwang91/nvim-ufo",
		cond = enabled(group, "ufo"),
		event = "VimEnter",
		dependencies = "kevinhwang91/promise-async",
		config = true,
	},
	{
		"epwalsh/obsidian.nvim",
		cond = enabled(group, "obsidian"),
		ft = "markdown",
		config = function()
			require("plugin-configs.obsidian")
		end,
	},
	{ "nvim-lua/plenary.nvim" },
	{
		"jedrzejboczar/possession.nvim",
		cond = enabled(group, "session_manager"),
		event = "VeryLazy",
		config = function()
			require("plugin-configs.possession")
		end,
	},
	{
		"ahmedkhalf/project.nvim",
		cond = enabled(group, "project"),
		event = "VimEnter",
		config = function()
			require("project_nvim").setup()
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		cond = enabled(group, "rustacean"),
		version = "^4",
		lazy = false, -- This plugin is already lazy
	},
	{
		"tiagovla/scope.nvim",
		cond = enabled(group, "scope"),
		event = "VimEnter",
		config = function()
			require("plugin-configs.scope")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cond = enabled(group, "telescope"),
		cmd = "Telescope",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		config = function()
			require("plugin-configs.telescope")
		end,
	},
	{
		"folke/todo-comments.nvim",
		cond = enabled(group, "todo_comments"),
		event = "VeryLazy",
		opts = {},
	},
	{
		"akinsho/toggleterm.nvim",
		cond = enabled(group, "toggleterm"),
		event = "VeryLazy",
		config = function()
			_G.term = require("plugin-configs.toggleterm")
		end,
	},
	{
		"folke/trouble.nvim",
		cond = enabled(group, "trouble"),
		cmd = "Trouble",
		config = function()
			require("plugin-configs.trouble")
		end,
	},
	{
		"folke/which-key.nvim",
		cond = enabled(group, "whichkey"),
		event = "VeryLazy",
		config = true,
	},
	{
		"folke/zen-mode.nvim",
		cond = enabled(group, "zen"),
		cmd = "ZenMode",
		config = function()
			require("plugin-configs.zenmode")
		end,
	},
	-- TODO: last vim script plugin for replacement
	-- blocked: https://github.com/brenton-leighton/multiple-cursors.nvim/issues/65
	-- {
	-- 	"mg979/vim-visual-multi",
	-- 	event = "VeryLazy",
	-- 	cond = enabled(group, "multicursor"),
	-- },
	{
		"brenton-leighton/multiple-cursors.nvim",
		opts = {}, -- This causes the plugin setup function to be called
		event = "VeryLazy",
	},
}, {
	defaults = { lazy = true },
	performance = {
		rtp = {
			disabled_plugins = { "tohtml", "gzip", "zipPlugin", "netrwPlugin", "tarPlugin" },
		},
	},
})
