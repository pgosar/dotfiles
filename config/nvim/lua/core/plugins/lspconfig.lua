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

    local function on_attach(client, bufnr)
      local wd_ok, wd = pcall(require, "workspace-diagnostics")
      if wd_ok then
        wd.populate_workspace_diagnostics(client, bufnr)

        -- HACK: For some reason the above method call causes lualine's diff view to break,
        -- and it only works again after re-entering the buffer which the below simulates
        vim.cmd([[silent! doautocmd BufLeave]])
        vim.cmd([[silent! doautocmd BufEnter]])
      end
    end

    -- Default configuration for all servers
    local default_config = {
      capabilities = capabilities,
      on_attach = on_attach,
    }

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
      local server_config = default_config

      if spec_ok then
        server_config = vim.tbl_deep_extend("force", {}, default_config, specific or {})
      else
        vim.notify(
          "Failed to load config for " .. server .. ": " .. tostring(specific),
          vim.log.levels.WARN
        )
      end
      vim.lsp.config(server, server_config)
    end

    -- Automatically enable Mason-installed servers with default config
    require("mason-lspconfig").setup({
      function(server_name)
        if server_name == "tsserver" then server_name = "ts_ls" end

        -- Skip if we've already configured this server above
        if not server_specific_configs[server_name] then
          vim.lsp.config(server_name, default_config)
          vim.lsp.enable(server_name)
        end
      end,
    })

    for server, _ in pairs(server_specific_configs) do
      vim.lsp.enable(server)
    end
  end,
  dependencies = {
    { "williamboman/mason-lspconfig.nvim" },
  },
}
