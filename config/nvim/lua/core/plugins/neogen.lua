return {
  "danymat/neogen",
  cond = group.plugins.neogen,
  keys = {
    { "<leader>fd", "<CMD>Neogen<CR>", desc = "generate doc comments" },
  },
  opts = { placeholders_hl = nil },
}
