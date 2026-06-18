require("nvim-treesitter").setup({
  ensure_installed = require("defaults").ensure_installed.treesitter,
  highlight = { enable = true },
  indent = { enable = true },
})
require("nvim-treesitter.install").update({ with_sync = true })
