local M = {}
local group = require("defaults").group

local function enabled(key) return key == nil or group.plugins[key] == true end

local specs = {
  blink = {
    key = "blink",
    packages = {
      { name = "friendly-snippets", key = "friendly_snippets" },
      { name = "blink.cmp", key = "blink" },
    },
    configs = { { module = "core.configs.blink", key = "blink" } },
  },
  dap = {
    key = "dap",
    packages = {
      { name = "nvim-nio", key = "nvim_nio" },
      { name = "nvim-dap", key = "dap" },
      { name = "nvim-dap-ui", key = "dap_ui" },
      { name = "nvim-dap-virtual-text", key = "dap_virtual_text" },
      { name = "nvim-dap-lldb", key = "dap_lldb" },
      { name = "nvim-dap-python", key = "dap_python" },
      { name = "mason-nvim-dap.nvim", key = "mason_nvim_dap" },
    },
    configs = { { module = "core.configs.dap", key = "dap" } },
  },
  edit_helpers = {
    packages = {
      { name = "gitsigns.nvim", key = "gitsigns" },
      { name = "nvim-highlight-colors", key = "highlight_colors" },
      { name = "indent-blankline.nvim", key = "indent_blankline" },
    },
    configs = {
      { module = "core.configs.gitsigns", key = "gitsigns" },
      { module = "core.configs.highlight_colors", key = "highlight_colors" },
      { module = "core.configs.indent_blankline", key = "indent_blankline" },
    },
  },
  flash = {
    key = "flash",
    packages = { { name = "flash.nvim", key = "flash" } },
    configs = { { module = "core.configs.flash", key = "flash" } },
  },
  fzf = {
    key = "fzf",
    packages = { { name = "fzf-lua", key = "fzf" } },
    configs = { { module = "core.configs.fzf", key = "fzf" } },
  },
  lsp = {
    key = "lspconfig",
    packages = {
      { name = "nvim-lspconfig", key = "lspconfig" },
      { name = "mason.nvim", key = "mason" },
      { name = "mason-lspconfig.nvim", key = "mason_lspconfig" },
      { name = "none-ls.nvim", key = "none_ls" },
      { name = "mason-null-ls.nvim", key = "mason_null_ls" },
      { name = "workspace-diagnostics.nvim", key = "workspace_diagnostics" },
      { name = "SchemaStore.nvim", key = "schemastore" },
      { name = "async.nvim", key = "async" },
      { name = "refactoring.nvim", key = "refactoring" },
      { name = "lazydev.nvim", key = "lazydev" },
    },
    configs = {
      { module = "core.configs.lazydev", key = "lazydev" },
      { module = "core.configs.lsp", key = "lspconfig" },
    },
  },
  markdown = {
    key = "markdown",
    packages = {
      { name = "markdown.nvim", key = "markdown" },
      { name = "markview.nvim", key = "markview" },
    },
    configs = { { module = "core.configs.markdown", key = "markdown" } },
  },
  mason = {
    key = "mason",
    packages = { { name = "mason.nvim", key = "mason" } },
    setup = function() require("mason").setup() end,
  },
  neogen = {
    key = "neogen",
    packages = { { name = "neogen", key = "neogen" } },
    configs = { { module = "core.configs.neogen", key = "neogen" } },
  },
  neotest = {
    key = "neotest",
    packages = {
      { name = "nvim-nio", key = "nvim_nio" },
      { name = "neotest", key = "neotest" },
    },
    configs = { { module = "core.configs.neotest", key = "neotest" } },
  },
  neotree = {
    key = "neotree",
    packages = {
      { name = "nui.nvim", key = "nui" },
      { name = "neo-tree.nvim", key = "neotree" },
    },
    configs = { { module = "core.configs.neotree", key = "neotree" } },
  },
  todo = {
    key = "todo_comments",
    packages = { { name = "todo-comments.nvim", key = "todo_comments" } },
    configs = { { module = "core.configs.todo", key = "todo_comments" } },
  },
  trouble = {
    key = "trouble",
    packages = { { name = "trouble.nvim", key = "trouble" } },
    configs = { { module = "core.configs.trouble", key = "trouble" } },
  },
  venn = {
    key = "venn",
    packages = { { name = "venn.nvim", key = "venn" } },
    configs = { { module = "core.configs.venn", key = "venn" } },
  },
}

function M.packadd(packages)
  for _, package in ipairs(packages) do
    local name = type(package) == "table" and package.name or package
    local key = type(package) == "table" and package.key or nil
    if enabled(key) then vim.cmd("packadd " .. name) end
  end
end

function M.load(name)
  local spec = specs[name]
  if not spec then error("Unknown plugin load spec: " .. tostring(name)) end
  if not enabled(spec.key) then
    vim.notify("Plugin disabled: " .. name, vim.log.levels.WARN)
    return false
  end

  M.packadd(spec.packages or {})
  for _, config in ipairs(spec.configs or {}) do
    if enabled(config.key) then require(config.module) end
  end
  if spec.setup and enabled(spec.key) then spec.setup() end
  return true
end

function M.with(name, callback)
  return function(...)
    if not M.load(name) then return end
    if callback then return callback(...) end
  end
end

M.enabled = enabled

return M
