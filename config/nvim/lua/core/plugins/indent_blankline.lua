-- Visual indent guides for better code structure visualization
return {
  "lukas-reineke/indent-blankline.nvim",
  cond = group.plugins.indent_blankline,
  event = "VeryLazy",
  main = "ibl",
  opts = {},
}
