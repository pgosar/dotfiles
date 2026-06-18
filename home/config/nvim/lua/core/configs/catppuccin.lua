local defaults = require("defaults")
local colors = defaults.colors.mocha_override
local plugins = defaults.group.plugins

require("catppuccin").setup({
  integrations = {
    alpha = false,
    gitsigns = plugins.gitsigns,
    hop = false,
    blink_cmp = plugins.blink,
    lsp_trouble = plugins.trouble,
    mason = plugins.mason,
    neotest = plugins.neotest,
    rainbow_delimiters = plugins.rainbow_delimiters,
    fzf = plugins.fzf,
    which_key = plugins.which_key,
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
