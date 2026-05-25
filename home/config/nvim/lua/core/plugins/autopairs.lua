-- Automatically pair matching brackets, quotes, etc.
return {
  "windwp/nvim-autopairs",
  cond = group.plugins.autopairs,
  event = "InsertEnter",
  opts = { map_c_w = true },
}
