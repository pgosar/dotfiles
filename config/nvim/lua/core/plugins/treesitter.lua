-- Syntax highlighting and code parsing engine
return {
  {
    "nvim-treesitter/nvim-treesitter",
    cond = group.plugins.treesitter,
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup()

      local parsers = require("defaults").ensure_installed.treesitter
      require("nvim-treesitter").install(parsers)
    end,
    dependencies = {
      { "HiPhish/rainbow-delimiters.nvim",            cond = group.plugins.rainbow },
      { "JoosepAlviste/nvim-ts-context-commentstring" },
    },
  },
}
