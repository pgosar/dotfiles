-- Default configuration values
local M = {}

-- Null-ls sources list
M.setup_sources = function(b)
  return {
    b.formatting.clang_format,
    b.formatting.stylua,
    b.formatting.cbfmt,
    b.formatting.shfmt.with({
      filetypes = {
        "sh",
        "bash",
        "zsh",
      },
    }),
    b.formatting.gofumpt,
    b.formatting.cmake_format,
    b.formatting.mdformat,
    b.formatting.prettierd.with({
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "html",
        "css",
        "json",
        "yaml",
        "yml",
      },
    }),
    b.formatting.verible_verilog_format,
    b.diagnostics.verilator,
    b.diagnostics.checkmake,
    b.diagnostics.cmake_lint,
    b.diagnostics.checkstyle.with({
      -- Default args scan $ROOT, which falls back to the home directory when
      -- no project root is found. Scan the project when one is detected,
      -- otherwise just the current file.
      args = function(params)
        local target = params.root
        local home = os.getenv("HOME")
        if not target or target == home then target = params.bufname end
        return { "-f", "sarif", target }
      end,
      extra_args = { "-c", "/google_checks.xml" },
    }),
    -- cppcheck exits 0 with findings; upstream expects >= 1.
    b.diagnostics.cppcheck.with({
      check_exit_code = function(code) return code <= 1 end,
    }),
    b.diagnostics.revive,
    b.diagnostics.selene.with({
      condition = function()
        return vim.fn.executable("selene") == 1
      end,
    }),
    b.code_actions.gitsigns,
    b.code_actions.gomodifytags,
    b.code_actions.refactoring,
  }
end

-- Auto install sources
M.ensure_installed = {
  treesitter = {
    "qmljs",
    "asm",
    "bash",
    "c",
    "cmake",
    "comment",
    "cpp",
    "css",
    "csv",
    "cuda",
    "diff",
    "disassembly",
    "dockerfile",
    "xml",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "glsl",
    "go",
    "gomod",
    "gosum",
    "html",
    "java",
    "javascript",
    "jsdoc",
    "json",
    "json5",
    "latex",
    "lua",
    "luap",
    "luau",
    "make",
    "markdown",
    "meson",
    "ninja",
    "objdump",
    "printf",
    "python",
    "regex",
    "ron",
    "rust",
    "scss",
    "toml",
    "tsx",
    "systemverilog",
    "wgsl",
    "yaml",
  },
  null_ls = {
    "rust_analyzer",
    "bash-language-server",
    "cbfmt",
    "clangd",
    "clang_format",
    "css-lsp",
    "debugpy",
    "delve",
    "gofumpt",
    "goimports_reviser",
    "gopls",
    "html_lsp",
    "jq",
    "json_lsp",
    "lua_language_server",
    "prettierd",
    "basedpyright",
    "shfmt",
    "stylua",
    "svlangserver",
    "typescript_language_server",
    "verible",
    "wgsl_analyzer",
    "mdformat",
    "zls",
    "qmlls",
    "shellcheck",
    "selene",
    "ruff",
    "taplo",
    "checkstyle",
    "markdownlint",
    "yamllint",
  },
  dap = {
    "python",
    "codelldb",
  },
}

M.settings = {
  bigfile_enable = true,
  bigfile_threshold = 100 * 1024 * 1024, -- 100 MB
}

-- Feature toggles read by config modules.
M.group = {
  plugins = {
    async = true,
    blink = true,
    bufferline = true,
    catppuccin = true,
    dap_python = true,
    dap = true,
    dap_lldb = true,
    dap_ui = true,
    dap_virtual_text = true,
    dropbar = true,
    flash = true,
    friendly_snippets = true,
    fzf = true,
    gitsigns = true,
    highlight_colors = true,
    indent_blankline = true,
    lazydev = true,
    lsp = true,
    lualine = true,
    markdown = true,
    markview = true,
    mason_lspconfig = true,
    mason_null_ls = true,
    mason_nvim_dap = true,
    mason = true,
    mini_ai = true,
    mini_align = true,
    neogen = true,
    neotest = true,
    neotree = true,
    none_ls = true,
    nui = true,
    nvim_nio = true,
    nvim_treesitter = true,
    nvim_ts_autotag = true,
    nvim_web_devicons = true,
    autopairs = true,
    plenary = true,
    rainbow_delimiters = true,
    refactoring = true,
    snacks = true,
    surround = true,
    todo_comments = true,
    trouble = true,
    venn = true,
    vim_visual_multi = true,
    notify = true,
    virt_column = true,
    which_key = true,
    workspace_diagnostics = true,
    snack_zen = true,
    snack_dashboard = true,
    snack_picker = true,
    snack_bufdelete = true,
    snack_statuscolumn = true,
    snack_rename = true,
    snack_image = true,
  },
  autocommands = {
    autosave = true,
    persistence = true,
    illuminate = true,
    trailing_whitespace = true,
    remember_file_state = true,
    term_spelling = true,
    number = true,
    comment = true,
    syncbackground = true,
    autoroot = true,
    term_line_numbers = true,
    autoformat = true,
  },
}

local theme = require("theme_colors")

M.colors = {
  mocha_override = {
    base = theme.surface,
    mantle = theme.surface,
    crust = theme.base,
  },
  lualine = {
    fg = theme.text,
    yellow = theme.yellow,
    cyan = theme.cyan,
    darkblue = theme.base,
    green = theme.green,
    orange = theme.peach,
    violet = theme.purple,
    magenta = theme.rose,
    blue = theme.blue,
    red = theme.red,
  },
}

M.plugin_settings = {
  autosave_delay = 10000, -- 10 seconds
  colorcolumn = "100",
  catppuccin_dim_percentage = 0.1,
  trouble_preview_size = 0.3,
}

M.colorscheme = "catppuccin"

_G.icons = {
  lualine = {
    lsp = " ",
  },
  comments = {
    fix = " ",
    todo = " ",
    hack = " ",
    warn = " ",
    perf = "󱑂 ",
    note = " ",
    test = "󰙨 ",
  },
  dashboard = {
    new_file = " ",
    find = " ",
    recent = " ",
    config = " ",
    session = " ",
    open_project = " ",
    quit = " ",
  },
  dap = {
    breakpoint = " ",
    stopped = "󰁕 ",
  },
  diagnostics = {
    error = " ",
    warn = " ",
    hint = "󰌵",
    info = " ",
    debug = " ",
    trace = "✎",
  },
  git = {
    branch = "",
    added = " ",
    modified = " ",
    removed = " ",
    renamed = " ",
    untracked = "",
    ignored = " ",
    unstaged = "󰄱 ",
    staged = " ",
    conflict = "",
  },
  lsp = {
    error = "✘",
    warn = "▲",
    hint = "⚑",
    info = "»",
  },
}

-- stylua: ignore
M.dashboard_ascii = table.concat({
  "           ⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀     ",
  "  ⠀⠀⠀⠀⠀ ⠀⠀⣴⣿⣿⠀⠀⠀⢠⣾⣧⣤⡖⠀⠀⠀⠀⠀⠀⠀  ",
  "⠀⠀⠀⠀⠀⠀ ⠀⢀⣼⠋⠀⠉⠀⢄⣸⣿⣿⣿⣿⣿⣥⡤⢶⣿⣦⣀⡀  ",
  "⠀⠀⠀⠀⠀ ⠀⠀⣿⣿⡆⠀⠀⠀⣙⣛⣿⣿⣿⣿⡏⠀⠀⣀⣿⣿⣿⡟  ",
  "⠀⠀⠀⠀ ⠀⠀⠀⠙⠻⠷⣦⣤⣤⣬⣽⣿⣿⣿⣿⣿⣿⣿⣟⠛⠿⠋⠀  ",
  "⠀⠀⠀ ⠀⠀⠀⠀⠀⠀⠀⢀⣴⠋⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⡆⠀⠀  ",
  "⠀⠀ ⠀⣠⣶⣶⣶⣿⣦⡀⠘⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⠈⢹⡏⠁⠀⠀  ",
  "⠀ ⠀⢀⣿⡏⠉⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡆⠀⢀⣿⡇⠀⠀⠀  ",
  " ⠀⠀⢸⣿⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡘⣿⣿⣃⠀⠀⠀  ",
  "⣴⣷⣀⣸⣿⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⠹⣿⣯⣤⣾⠏⠉⠉⠉⠙⠢⠀  ",
  "⠈⠙⢿⣿⡟⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣄⠛⠉⢩⣷⣴⡆⠀⠀⠀⠀⠀  ",
  "⠀⠀⠀⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣀⡠⠋⠈⢿⣇⠀⠀     ",
  " ⠀⠀          ⠙⠿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀   ",
}, "\n") .. "\n"

return M
