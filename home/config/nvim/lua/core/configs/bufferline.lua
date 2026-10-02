require("bufferline").setup({
  highlights = {
    fill = { bg = require("theme_colors").base },
    background = { bg = require("theme_colors").base },
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
