return {
  "Bekaboo/dropbar.nvim",
  priority = 2000,
  lazy = false,
  cond = group.plugins.dropbar,
  keys = {
    { "<C-p>", function() require("dropbar.api").pick() end, { desc = "pick from dropbar" }, },
  },
}
