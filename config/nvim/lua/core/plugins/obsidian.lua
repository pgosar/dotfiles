return {
  "epwalsh/obsidian.nvim",
  cond = group.plugins.obsidian,
  ft = "markdown",
  keys = {
    { "<leader>p",   "<CMD>ObsidianPasteImg<CR>", desc = "Paste clipboard image" },
    { "<leader>ol",  "<CMD>ObsidianLink<CR>",     mode = "v",                    desc = "Link current word to file in Obsidian" },
    { "<leader>oln", "<CMD>ObsidianLinkNew<CR>",  mode = "v",                    desc = "Link current word to new file in Obsidian" },
    { "<leader>on",  "<CMD>ObsidianNew<CR>",      desc = "New file in Obsidian" },
  },
  opts = {
    ui = { enable = false },
    mappings = {
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    note_id_func = function(title)
      local suffix = ""
      if title == nil then
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
        return suffix
      end
      return title
    end,
    preferred_link_style = "markdown",
    workspaces = {
      {
        name = "notes",
        path = "~/Documents/notes/docs",
      },
      {
        name = "no-vault",
        path = function()
          return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
        overrides = {
          notes_subdir = vim.NIL,
          new_notes_location = "current_dir",
          templates = { subdir = vim.NIL },
          disable_frontmatter = true,
        },
      },
    },
  },
}

