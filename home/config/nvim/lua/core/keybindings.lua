-- Global keybindings
local map = require("core.utils.utils").map

-- Searching and Highlighting
map("n", "m", "<CMD>noh<CR>", { desc = "clear search highlight" })

-- Movement
-- in insert mode, type <c-d> and your cursor will move past the next separator
-- such as quotes, parens, brackets, etc.
map(
  "i",
  "<C-d>",
  "<CMD>set shortmess+=S<CR><left><c-o>/[\"';)>{}\\]]<cr><c-o><CMD>noh<CR><CMD>set shortmess-=S<CR><right>",
  { desc = "move past separator" }
)
map("i", "<C-b>", "<C-o>0", { desc = "move to beginning of line" })
map("i", "<C-a>", "<C-o>A", { desc = "move to end of line" })

-- Window switching from terminal
map("t", "<C-w>h", "<C-\\><C-n><C-w>h", { desc = "move to left window from terminal" })
map("t", "<C-w>j", "<C-\\><C-n><C-w>j", { desc = "move to bottom window from terminal" })
map("t", "<C-w>k", "<C-\\><C-n><C-w>k", { desc = "move to top window from terminal" })
map("t", "<C-w>l", "<C-\\><C-n><C-w>l", { desc = "move to right window from terminal" })

-- Escape terminal mode natively
map("t", "<C-\\>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

-- Switching buffers
map("n", "<leader>bn", "<CMD>bnext<CR>", { desc = "switch to next buffer" })
map("n", "<leader>bp", "<CMD>bprevious<CR>", { desc = "switch to prev buffer" })

-- Window resizing
-- +/- keys with shift modifier
map("n", "-", ":resize +2<CR>", { desc = "resize window down" })
map("n", "=", ":resize -2<CR>", { desc = "resize window up" })
map("n", "_", ":vertical resize -2<CR>", { desc = "resize window left" })
map("n", "+", ":vertical resize +2<CR>", { desc = "resize window right" })

-- cut without yanking, since v/V with x is also cut
map("n", "X", "D", { desc = "cut and yank" })
map({ "n", "v" }, "d", '"_d', { desc = "cut without yanking" })

map(
  "i",
  "<C-c>",
  function() require("core.utils.utils").close_floating_windows() end,
  { desc = "close all floating windows when in insert mode" }
)

-- Native line moving
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move text down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move text up" })
map("v", "<A-h>", "<gv", { desc = "Move text left" })
map("v", "<A-l>", ">gv", { desc = "Move text right" })

-- Native floating terminal
map(
  "n",
  "<leader><C-\\>",
  function() require("core.utils.terminal").toggle_terminal() end,
  { desc = "Toggle floating terminal" }
)
map(
  "n",
  "<leader>gg",
  function() require("core.utils.terminal").toggle_terminal("lazygit") end,
  { desc = "Open lazygit" }
)
map(
  "n",
  "<leader>tk",
  function() require("core.utils.terminal").toggle_terminal("tokei") end,
  { desc = "Open tokei" }
)

-- Native session
map(
  "n",
  "<leader>qL",
  function() require("core.utils.session").load_session() end,
  { desc = "Load current directory's session" }
)
map(
  "n",
  "<leader>ql",
  function() require("core.utils.session").load_last_session() end,
  { desc = "Load last session" }
)
map(
  "n",
  "<leader>qd",
  function() require("core.utils.session").stop_session() end,
  { desc = "Don't save session" }
)

-- Lazy loaded plugins wrappers

-- FZF-Lua Loader
local function load_fzf(action)
  return function()
    vim.cmd("packadd fzf-lua")
    require("core.configs.fzf")
    require("fzf-lua")[action]()
  end
end
map("n", "<leader>ff", load_fzf("files"), { desc = "Find files" })
map("n", "<leader>fg", load_fzf("live_grep"), { desc = "Grep for text" })
map("n", "<leader>fb", load_fzf("buffers"), { desc = "Search through open buffers" })

-- Neo-tree Loader
map("n", "<leader>nt", function()
  vim.cmd("packadd nui.nvim")
  vim.cmd("packadd neo-tree.nvim")
  require("core.configs.neotree")
  require("neo-tree.command").execute({ toggle = true, reveal = true, position = "float" })
end, { desc = "toggle neotree" })

-- Trouble Loader
local function load_trouble(mode)
  return function()
    vim.cmd("packadd trouble.nvim")
    require("core.configs.trouble")
    require("trouble").toggle(mode)
  end
end
map("n", "<leader>tf", load_trouble("diagnostics"), { desc = "Trouble toggle diagnostics" })
map("n", "<leader>tt", load_trouble("todo"), { desc = "Trouble toggle todo" })
map("n", "<leader>ts", load_trouble("symbols"), { desc = "Trouble toggle symbols" })
map("n", "<leader>tl", load_trouble("lsp"), { desc = "Trouble toggle lsp" })

-- Neogen Loader
map("n", "<leader>fd", function()
  vim.cmd("packadd neogen")
  require("core.configs.neogen")
  require("neogen").generate()
end, { desc = "generate doc comments" })

-- Neotest Loader
map("n", "<leader>nr", function()
  vim.cmd("packadd nvim-nio")
  vim.cmd("packadd neotest")
  require("core.configs.neotest")
  require("neotest").run.run()
end, { desc = "run test with neotest" })

-- DAP Loader
local function load_dap(callback)
  return function()
    local dap_plugins = {
      "nvim-nio",
      "nvim-dap",
      "nvim-dap-ui",
      "nvim-dap-virtual-text",
      "nvim-dap-lldb",
      "nvim-dap-python",
      "mason-nvim-dap.nvim",
    }
    for _, p in ipairs(dap_plugins) do
      vim.cmd("packadd " .. p)
    end
    require("core.configs.dap")
    callback()
  end
end
map(
  "n",
  "<leader>dc",
  load_dap(function() require("dap").continue() end),
  { desc = "Debugger Continue" }
)
map(
  "n",
  "<leader>dn",
  load_dap(function() require("dap").step_over() end),
  { desc = "Debugger Step Over" }
)
map(
  "n",
  "<leader>di",
  load_dap(function() require("dap").step_into() end),
  { desc = "Debugger Step Into" }
)
map(
  "n",
  "<leader>do",
  load_dap(function() require("dap").step_out() end),
  { desc = "Debugger Step Out" }
)
map(
  "n",
  "<leader>db",
  load_dap(function() require("dap").toggle_breakpoint() end),
  { desc = "Toggle Breakpoint" }
)
map(
  "n",
  "<leader>dq",
  load_dap(function() require("dap").disconnect({ terminateDebuggee = true }) end),
  { desc = "Disconnect Debugger" }
)

-- Venn Loader keybinding
map("n", "<leader>v", ":ToggleVenn<CR>", { desc = "toggle venn" })

-- Snacks Zen Mode keybinding (Snacks is a start plugin)
map("n", "<leader>zm", function() require("snacks").zen() end, { desc = "Toggle Zen Mode" })

-- Flash Loader keybindings
local function load_flash(action)
  return function()
    vim.cmd("packadd flash.nvim")
    require("core.configs.flash")
    require("flash")[action]()
  end
end
map({ "n", "x", "o" }, "<leader>j", load_flash("jump"), { desc = "Flash" })
map({ "n", "x", "o" }, "<leader>J", load_flash("treesitter"), { desc = "Flash Treesitter" })

-- Multicursor (vim-visual-multi) keybindings
map("n", "<C-k>", "<Plug>(VM-Add-Cursor-Up)", { desc = "add multi cursor up", silent = true })
map("n", "<C-j>", "<Plug>(VM-Add-Cursor-Down)", { desc = "add multi cursor down", silent = true })

-- Dropbar keybindings
if group.plugins.dropbar then
  map("n", "<C-p>", function() require("dropbar.api").pick() end, { desc = "Pick from dropbar" })
end
