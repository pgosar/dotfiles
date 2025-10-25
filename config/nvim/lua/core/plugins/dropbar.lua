return {
  "Bekaboo/dropbar.nvim",
  lazy = false,
  cond = group.plugins.dropbar,
  -- stylua: ignore
  keys = {
    { "<C-p>", function() require("dropbar.api").pick() end, { desc = "pick from dropbar" }, },
  },
}
