-- Fancy notifications
return {
  "rcarriga/nvim-notify",
  cond = group.plugins.notify,
  lazy = false,
  keys = {
    {
      "<ESC>",
      function() require("notify").dismiss({}) end,
      desc = "Dismiss notifications",
    },
    {
      "<ESC>",
      function()
        require("notify").dismiss({})
        vim.cmd("stopinsert")
      end,
      mode = "i",
      desc = "Dismiss notifications",
    },
  },
  opts = {
    top_down = true,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 175 })
    end,
    icons = {
      ERROR = icons.diagnostics.error,
      WARN = icons.diagnostics.warn,
      INFO = icons.diagnostics.info,
      DEBUG = icons.diagnostics.debug,
      TRACE = icons.diagnostics.trace,
    },
  },
}
