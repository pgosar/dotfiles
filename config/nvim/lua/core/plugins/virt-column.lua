-- Display vertical guide line
return {
  "lukas-reineke/virt-column.nvim",
  cond = group.plugins.virt_column,
  event = "VeryLazy",
  opts = { virtcolumn = require("defaults").plugin_settings.virt_column },
}
