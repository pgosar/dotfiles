return {
	"hrsh7th/nvim-cmp",
	cond = group.plugins.cmp,
	event = { "InsertEnter", "CmdlineEnter" },
	config = function()
		---@diagnostic disable: undefined-field
		local cmp = require("cmp")
		require("cmp")
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		local has_words_before = require("core.utils.utils").has_words_before
		local neogen = require("neogen")
		cmp.setup({
			enabled = function()
				-- disables in certain filetypes
				if vim.bo.filetype == "text" or vim.bo.filetype == "gitrebase" or vim.bo.filetype == "gitcommit" then
					return false
				end
				-- disables in comments
				-- TODO: neogen references in this file are contingent on the issue resolved (see neogen
				-- config)
				local context = require("cmp.config.context")
				if vim.api.nvim_get_mode().mode == "c" then
					return true
				else
					return not context.in_treesitter_capture("comment")
						and not context.in_syntax_group("Comment")
						and not neogen.jumpable()
				end
			end,
			preselect = "none",
			completion = {
				keyword_length = 1,
				completeopt = "menu,menuone,noinsert,noselect",
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			formatting = {
				fields = { "abbr", "kind", "menu" },
				format = function(entry, item)
					local color = require("nvim-highlight-colors").format(entry, { kind = item.kind })
					item = require("lspkind").cmp_format({
						maxwidth = 50,
						ellipsis_char = "...",
						mode = "symbol_text",
						symbol_map = { Copilot = "" },
						show_labelDetails = true,
					})(entry, item)
					if color.abbr_hl_group then
						item.kind_hl_group = color.abbr_hl_group
						item.kind = color.abbr
					end
					return item
				end,
			},
			mapping = {
				["<CR>"] = cmp.mapping({
					-- for some reason if I don't do this it complains about ambiguous commands
					i = cmp.mapping.confirm({ select = false }),
					c = cmp.mapping.confirm({ select = false }),
				}),
				["<Tab>"] = cmp.mapping(function(fallback)
					if neogen.jumpable() then
						neogen.jump_next()
					elseif cmp.visible() then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					elseif vim.snippet.active({ direction = 1 }) then
						vim.snippet.jump(1)
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s", "c" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if neogen.jumpable(true) then
						neogen.jump_prev()
					elseif cmp.visible() then
						cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
					elseif vim.snippet.active({ direction = -1 }) then
						vim.snippet.jump(-1)
					else
						fallback()
					end
				end, { "i", "s", "c" }),
				["<C-c>"] = cmp.mapping.abort(),
				["<C-n>"] = { i = cmp.mapping.complete() },
			},
			sources = {
				{ name = "copilot" },
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "snippets" },
				{ name = "path", option = { trailing_slash = true } },
			},
		})

		-- `/` cmdline setup.
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- `:` cmdline setup.
		cmp.setup.cmdline(":", {
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{
					name = "cmdline",
					option = {
						ignore_cmds = { "Man", "!" },
					},
				},
			}),
		})
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
}
