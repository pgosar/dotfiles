local group = require("defaults").group

-- 1. Setup Mason
if group.plugins.mason then require("mason").setup({}) end

-- 2. Setup Diagnostics Options
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
  float = { border = "rounded" },
})

-- 3. Set global default capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
vim.lsp.config("*", { capabilities = capabilities })

-- 4. Setup LspAttach autocommand for keybindings and Workspace Diagnostics
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local bufnr = args.buf
    local function buf_map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    buf_map("n", "grD", vim.lsp.buf.declaration, "Go to Declaration")
    buf_map("n", "grd", vim.lsp.buf.definition, "Go to Definition")
    if group.plugins.snacks and group.plugins.snack_rename then
      buf_map("n", "<leader>grn", function()
        if Snacks and Snacks.rename then Snacks.rename.rename_file() end
      end, "Rename files")
    end
    buf_map(
      "n",
      "<C-h>",
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end,
      "Toggle Inlay Hints"
    )

    local wd_ok, wd = false, nil
    if group.plugins.workspace_diagnostics then
      wd_ok, wd = pcall(require, "workspace-diagnostics")
    end
    local populate_workspace_diagnostics = type(wd) == "table"
      and wd["populate_workspace_diagnostics"]
    if wd_ok and type(populate_workspace_diagnostics) == "function" then
      populate_workspace_diagnostics(client, bufnr)
      if bufnr == vim.api.nvim_get_current_buf() then
        vim.cmd([[silent! doautocmd BufLeave]])
        vim.cmd([[silent! doautocmd BufEnter]])
      end
    end
  end,
})

-- 5. Setup Language Servers configs
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

-- 6. Setup Mason LSPConfig
local ml_ok, mason_lspconfig = false, nil
if group.plugins.mason_lspconfig then
  ml_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
end
local mason_lspconfig_setup = type(mason_lspconfig) == "table" and mason_lspconfig["setup"]
if ml_ok and type(mason_lspconfig_setup) == "function" then
  mason_lspconfig_setup({ automatic_enable = true })
end

-- 7. Enable servers
for server, _ in pairs(server_specific_configs) do
  vim.lsp.enable(server)
end

-- 8. Setup none-ls (null-ls) and mason-null-ls
if group.plugins.none_ls then
  local null_ls = require("null-ls")
  null_ls.setup({
    sources = require("defaults").setup_sources(null_ls.builtins),
  })
  local mn_ok, mason_null_ls = false, nil
  if group.plugins.mason_null_ls then
    mn_ok, mason_null_ls = pcall(require, "mason-null-ls")
  end
  local mason_null_ls_setup = type(mason_null_ls) == "table" and mason_null_ls["setup"]
  if mn_ok and type(mason_null_ls_setup) == "function" then
    mason_null_ls_setup({
      ensure_installed = require("defaults").ensure_installed.null_ls,
      automatic_installation = true,
    })
  end
end

-- 9. Setup Refactoring
local ref_ok, refactoring = false, nil
if group.plugins.refactoring then
  ref_ok, refactoring = pcall(require, "refactoring")
end
local refactoring_setup = type(refactoring) == "table" and refactoring["setup"]
if ref_ok and type(refactoring_setup) == "function" then
  refactoring_setup({ show_success_message = true })
end
