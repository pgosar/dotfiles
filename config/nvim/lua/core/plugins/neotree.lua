return {
  "nvim-neo-tree/neo-tree.nvim",
  cond = group.plugins.neotree,
  cmd = "Neotree",
  keys = {
    {
      "<leader>nt",
      function()
        require("neo-tree.command").execute({ toggle = true, reveal = true, position = "float" })
      end,
      desc = "toggle neotree",
    },
  },
  opts = {
    close_if_last_window = true,
    default_component_configs = {
      modified = {
        symbol = icons.git.modified,
      },
      git_status = {
        symbols = {
          added = icons.git.added,
          modified = icons.git.modified,
          deleted = icons.git.removed,
          renamed = icons.git.renamed,
          -- Status type
          untracked = icons.git.untracked,
          ignored = icons.git.ignored,
          unstaged = icons.git.unstaged,
          staged = icons.git.staged,
          conflict = icons.git.conflict,
        },
      },
    },
    window = {
      mappings = {
        ["C"] = "close_all_subnodes",
        ["Z"] = "expand_all_nodes",
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      window = {
        mappings = {
          ["/"] = "filter_on_submit",
        },
      },
      hijack_netrw_behavior = "open_current",
    },
  },
  init = function()
    local stats = vim.uv.fs_stat(vim.fn.argv(0))
    if stats and stats.type == "directory" then require("neo-tree") end
  end,
  branch = "v3.x",
  dependencies = { "nvim-tree/nvim-web-devicons", "3rd/image.nvim" },
}
