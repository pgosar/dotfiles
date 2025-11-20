-- UI enhancements
return {
  "folke/noice.nvim",
  cond = group.plugins.noice,
  event = "VeryLazy",
  config = function()
    local ok, _ = pcall(require, "notify")
    require("noice").setup({
      messages = {
        view = "mini",
        view_search = "mini",
      },
      routes = {
        {
          view = ok and "notify" or "mini",
          filter = {
            event = "msg_show",
            find = "substitutions",
          },
        },
        { filter = { find = "fewer lines" }, opts = { skip = true } },
        { filter = { find = "more line" }, opts = { skip = true } },
        { filter = { find = "more lines" }, opts = { skip = true } },
        { filter = { find = "less" }, opts = { skip = true } },
        { filter = { find = "change;" }, opts = { skip = true } },
        { filter = { find = "changes;" }, opts = { skip = true } },
        { filter = { find = "indent" }, opts = { skip = true } },
        { filter = { find = "move" }, opts = { skip = true } },
        { filter = { find = "Processing file symbols" }, opts = { skip = true } },
        { filter = { find = "Diagnosing" }, opts = { skip = true } },
        -- NOTE: these rust-analyzer errors appear to be an upstream neovim bug
        { filter = { find = "left == right" }, opts = { skip = true } },
        { filter = { find = "-32603" }, opts = { skip = true } },
        { filter = { find = "-32802" }, opts = { skip = true } },
      },
      cmdline = { view = "cmdline" },
      views = {
        popupmenu = {
          size = require("defaults").plugin_settings.noice_popupmenu,
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
      lsp = {
        message = {
          enabled = false,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        signature = { enabled = false },
        hover = { enabled = false },
      },
      presets = {
        bottom_search = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    })
  end,
  dependencies = { { "MunifTanjim/nui.nvim" } },
}
