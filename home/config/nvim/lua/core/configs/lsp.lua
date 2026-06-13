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
    buf_map("n", "<leader>grn", function() Snacks.rename.rename_file() end, "Rename files")
    buf_map(
      "n",
      "<C-h>",
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end,
      "Toggle Inlay Hints"
    )

    local wd_ok, wd = pcall(require, "workspace-diagnostics")
    if wd_ok then
      wd.populate_workspace_diagnostics(client, bufnr)
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
local ml_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if ml_ok then mason_lspconfig.setup({ automatic_enable = true }) end

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
  local mn_ok, mason_null_ls = pcall(require, "mason-null-ls")
  if mn_ok then
    mason_null_ls.setup({
      ensure_installed = require("defaults").ensure_installed.null_ls,
      automatic_installation = true,
    })
  end
end

-- 9. Setup Refactoring
local ref_ok, refactoring = pcall(require, "refactoring")
if ref_ok then refactoring.setup({ show_success_message = true }) end
