-- LSP configuration
return {
  "neovim/nvim-lspconfig",
  cond = group.plugins.lspconfig,
  event = { "BufReadPre", "BufNewFile" },

  keys = {
    { "grD", vim.lsp.buf.declaration, desc = "Go to Declaration" },
    { "grd", vim.lsp.buf.definition, desc = "Go to Definition" },
    { "<leader>grn", function() Snacks.rename.rename_file() end, desc = "Rename files" },
    {
      "<C-h>",
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end,
      desc = "Toggle Inlay Hints",
    },
  },
  config = function()
    -- Configure diagnostics
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = icons.lsp.error,
          [vim.diagnostic.severity.WARN] = icons.lsp.warn,
          [vim.diagnostic.severity.HINT] = icons.lsp.hint,
          [vim.diagnostic.severity.INFO] = icons.lsp.info,
        },
      },
      virtual_text = true,
      severity_sort = true,
      float = {
        border = "rounded",
      },
    })

    -- Set up capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument = capabilities.textDocument or {}
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }

    -- Define global default capabilities
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    -- Handle LspAttach for all servers (migrated from on_attach callback)
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        local wd_ok, wd = pcall(require, "workspace-diagnostics")
        if wd_ok then
          wd.populate_workspace_diagnostics(client, args.buf)

          -- HACK: For some reason the above method call causes lualine's diff view to break,
          -- and it only works again after re-entering the buffer which the below simulates
          if args.buf == vim.api.nvim_get_current_buf() then
            vim.cmd([[silent! doautocmd BufLeave]])
            vim.cmd([[silent! doautocmd BufEnter]])
          end
        end
      end,
    })

    -- Load server-specific configurations
    local server_specific_configs = {
      gopls = "language-server-configs.gopls",
      ts_ls = "language-server-configs.tsserver",
      lua_ls = "language-server-configs.lua_ls",
      bashls = "language-server-configs.bashls",
      rust_analyzer = "language-server-configs.rust-analyzer",
      clangd = "language-server-configs.clangd",
      basedpyright = "language-server-configs.basedpyright",
    }

    for server, config_module in pairs(server_specific_configs) do
      local spec_ok, specific = pcall(require, config_module)

      if spec_ok then
        vim.lsp.config(server, specific or {})
      else
        vim.notify(
          "Failed to load config for " .. server .. ": " .. tostring(specific),
          vim.log.levels.WARN
        )
      end
    end

    -- Automatically enable Mason-installed servers with default config
    require("mason-lspconfig").setup({
      automatic_enable = true,
    })

    for server, _ in pairs(server_specific_configs) do
      vim.lsp.enable(server)
    end
  end,
  dependencies = {
    { "williamboman/mason-lspconfig.nvim" },
  },
}
