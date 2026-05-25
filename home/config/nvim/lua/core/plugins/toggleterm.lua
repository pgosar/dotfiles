-- Terminal manager 
return {
  "akinsho/toggleterm.nvim",
  cond = group.plugins.toggleterm,
  keys = {
    {
      "<leader><C-\\>",
      function() require("toggleterm").toggle(0, nil, nil, "float") end,
      desc = "Toggle floating terminal",
    },
    {
      "<C-\\>",
      "<C-\\><C-n>",
      mode = "t",
      desc = "Toggle terminal",
    },
    {
      "<C-\\>",
      function() require("toggleterm").toggle() end,
      desc = "Toggle terminal",
    },
    {
      "<leader>tk",
      function()
        require("toggleterm.terminal").Terminal:new({ cmd = "tokei", direction = "float" }):toggle()
      end,
      desc = "Open tokei",
    },
    {
      "<leader>gg",
      function() require("core.utils.utils").create_floating_terminal("lazygit") end,
      desc = "open lazygit",
    },
  },
  opts = {
    size = require("defaults").plugin_settings.toggleterm_size,
    shade_terminals = false,
    start_in_insert = true,
    highlights = {
      Normal = {
        guibg = require("defaults").colors.terminal,
      },
    },
    direction = "horizontal",
    float_opts = { border = "curved" },
  },
}
