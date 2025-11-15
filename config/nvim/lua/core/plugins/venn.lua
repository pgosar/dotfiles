return {
  "jbyuki/venn.nvim",
  cond = group.plugins.venn,
  keys = {
    { "<leader>v", ":ToggleVenn<CR>", desc = "toggle venn" },
  },
  init = function()
    vim.api.nvim_create_user_command("ToggleVenn", function()
      local venn_enabled = vim.inspect(vim.b.venn_enabled)
      if venn_enabled == "nil" then
        vim.notify("Venn enabled", "info", { title = "Venn" })
        local map = require("core.utils.utils").map
        vim.b.venn_enabled = true
        vim.cmd([[setlocal ve=all]])
        map("n", "H", "<C-v>h:VBox<CR>", { buffer = true })
        map("n", "J", "<C-v>j:VBox<CR>", { buffer = true })
        map("n", "K", "<C-v>k:VBox<CR>", { buffer = true })
        map("n", "L", "<C-v>l:VBox<CR>", { buffer = true })
        map("x", "f", ":VBox<CR>", { buffer = true })
        map("x", "D", ":VBoxD<CR>", { buffer = true })
        map("x", "F", ":VBoxH<CR>", { buffer = true })
        map("x", "O", ":VBoxO<CR>", { buffer = true })
        map("x", "P", ":VFill<CR>", { buffer = true })
      else
        vim.notify("Venn disabled", "info", { title = "Venn" })
        vim.cmd([[setlocal ve=]])
        local del = vim.keymap.del
        del("n", "H", { buffer = true })
        del("n", "J", { buffer = true })
        del("n", "K", { buffer = true })
        del("n", "L", { buffer = true })
        del("x", "f", { buffer = true })
        del("x", "F", { buffer = true })
        del("x", "D", { buffer = true })
        del("x", "O", { buffer = true })
        del("x", "P", { buffer = true })
        vim.b.venn_enabled = nil
      end
    end, { nargs = 0, desc = "Toggle venn" })
  end,
}
