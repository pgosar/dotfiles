local defaults = require("defaults")
local colors = defaults.colors.mocha_override
local plugins = defaults.group.plugins
local theme = require("theme_colors")
local flavour = theme.mode == "light" and "latte" or "mocha"

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
  flavour = flavour,
  color_overrides = {
    [flavour] = {
      base = colors.base,
      mantle = colors.mantle,
      crust = colors.crust,
    },
  },
})
