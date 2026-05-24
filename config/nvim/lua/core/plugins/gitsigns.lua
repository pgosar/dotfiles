-- Git integration
return {
  "lewis6991/gitsigns.nvim",
  cond = group.plugins.gitsigns,
  event = "VeryLazy",
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        opts.noremap = true
        opts.silent = true
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      map("n", "]h", function() gs.nav_hunk("next") end, { desc = "go to next hunk" })
      map("n", "[h", function() gs.nav_hunk("prev") end, { desc = "go to prev hunk" })
      map("n", "<leader>hs", gs.stage_hunk, { desc = "stage hunk" })
      map("n", "<leader>hr", gs.reset_hunk, { desc = "reset hunk" })
      map("n", "<leader>hS", gs.stage_buffer, { desc = "stage buffer" })
      map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
      map("n", "<leader>hR", gs.reset_buffer, { desc = "reset buffer" })
      map("n", "<leader>hp", gs.preview_hunk, { desc = "preview hunk" })
      map(
        "n",
        "<leader>hb",
        function() gs.blame_line({ full = true }) end,
        { desc = "complete blame line history" }
      )
      map("n", "<leader>lb", gs.toggle_current_line_blame, { desc = "toggle blame line" })
      map("n", "<leader>hd", gs.diffthis, { desc = "diff at cwd" })
      map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "diff at root of git repo" })
      map("n", "<leader>td", gs.toggle_deleted, { desc = "toggle deleted line" })
    end,
  },
}
