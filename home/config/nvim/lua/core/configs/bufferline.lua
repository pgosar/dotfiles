-- Bar background: a shade darker than the lualine bar in light mode
local theme = require("theme_colors")
local bar_bg = vim.o.background == "light" and "#d8dade" or theme.surface
require("bufferline").setup({
  highlights = {
    fill = { bg = bar_bg },
    background = { bg = bar_bg },
  },
  options = {
    diagnostics = "nvim_lsp",
    separator_style = "thin",
    diagnostics_indicator = function(count, level)
      local icon = level:match("error") and icons.diagnostics.error or icons.diagnostics.warn
      return " " .. icon .. count
    end,
  },
})
