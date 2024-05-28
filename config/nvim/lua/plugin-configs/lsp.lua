local lsp = require("lsp-zero")
lsp.preset("minimal")

lsp.set_sign_icons({
	error = "✘",
	warn = "▲",
	hint = "⚑",
	info = "»",
})


lsp.set_server_config({
	capabilities = {
		textDocument = {
			foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			},
		},
		offsetEncoding = { "utf-16" },
	},
})

local exist, user_config = pcall(require, "user_config")
local formatting_servers = exist and type(user_config) == "table" and user_config.formatting_servers or {}
lsp.format_on_save({
	format_opts = {
		async = false,
		timeout_ms = 10000,
	},
	servers = formatting_servers,
})
local lspconfig = require("lspconfig")
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({})
    end,
  },
})
