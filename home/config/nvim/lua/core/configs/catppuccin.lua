local colors = require("defaults").colors.mocha_override
require("catppuccin").setup({
  integrations = {
    alpha = true,
    gitsigns = true,
    hop = true,
    blink_cmp = true,
    lsp_trouble = true,
    mason = true,
    neotest = true,
    rainbow_delimiters = true,
    fzf = true,
    which_key = true,
  },
  dim_inactive = {
    enabled = true,
    percentage = require("defaults").plugin_settings.catppuccin_dim_percentage,
  },
  flavour = "mocha",
  color_overrides = {
    mocha = {
      base = colors.base,
      mantle = colors.mantle,
      crust = colors.crust,
    },
  },
})
