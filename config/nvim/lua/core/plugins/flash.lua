return {
  "folke/flash.nvim",
  cond = group.plugins.flash,
  keys = {
    { "<leader>j", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
    { "<leader>J", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" }, },
  opts = {
    modes = {
      char = { jump_labels = true },
    },
  },
}
