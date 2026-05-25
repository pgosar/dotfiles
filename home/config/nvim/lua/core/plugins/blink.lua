-- Autocomplete
return {
  "saghen/blink.cmp",
  cond = group.plugins.blink,
  event = { "InsertEnter", "CmdlineEnter" },
  version = "v0.*",
  dependencies = { { "rafamadriz/friendly-snippets" } },
  config = function()
    local neogen_ok, neogen = pcall(require, "neogen")
    local blink = require("blink.cmp")
    blink.setup({
      enabled = function()
        -- disable in certain filetypes
        return not vim.tbl_contains({ "text", "gitcommit", "gitrebase" }, vim.bo.filetype)
          and vim.bo.buftype ~= "prompt"
      end,
      completion = {
        trigger = { prefetch_on_insert = true },
        list = {
          selection = { preselect = false, auto_insert = false },
          max_items = 20,
        },
        accept = { auto_brackets = { enabled = true } },
        menu = {
          border = "rounded",
          scrolloff = 0,
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind", gap = 1 },
            },
          },
        },
        documentation = {
          window = { border = "rounded" },
          auto_show = true,
          auto_show_delay_ms = 0,
        },
      },
      sources = {
        providers = {
          buffer = { enabled = false },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },

          lsp = {
            transform_items = function(_, items)
              -- Remove the "Text" source from lsp autocomplete
              return vim.tbl_filter(
                function(item) return item.kind ~= vim.lsp.protocol.CompletionItemKind.Text end,
                items
              )
            end,
          },
        },
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
      keymap = {
        preset = "enter",
        ["C-c"] = { "hide", "fallback" },
        ["<Tab>"] = {
          function()
            if neogen_ok and neogen.jumpable() then neogen.jump_next() end
          end,
          "select_next",
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function()
            if neogen_ok and neogen.jumpable(1) then neogen.jump_prev() end
          end,
          "select_prev",
          "snippet_forward",
          "fallback",
        },
      },
    })
  end,
}
