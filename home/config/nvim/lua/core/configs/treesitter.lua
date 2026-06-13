require("nvim-treesitter").setup({
  highlight = { enable = true },
  indent = { enable = true },
})
local parsers = require("defaults").ensure_installed.treesitter
require("nvim-treesitter.install").update({ with_sync = true })
