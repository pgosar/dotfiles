-- Autocommands
local augroup = require("core.utils.utils").augroup
local cmd = vim.api.nvim_create_autocmd

-- Removes any trailing white space when saving a file
if group.autocommands.trailing_whitespace then
  cmd({ "BufWritePre" }, {
    desc = "remove trailing whitespace on save",
    group = augroup("remove trailing whitespace"),
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
  })
end

-- Remembers file state, such as cursor position and any folds
if group.autocommands.remember_file_state then
  augroup("remember file state")
  cmd({ "BufWinLeave" }, {
    desc = "remember file state",
    group = "remember file state",
    pattern = { "*.*" },
    command = "mkview",
  })
  cmd({ "BufWinEnter" }, {
    desc = "remember file state",
    group = "remember file state",
    pattern = { "*.*" },
    command = "silent! loadview",
  })
end

-- No spellcheck in terminal buffers
if group.autocommands.term_spelling then
  cmd({ "TermOpen" }, {
    desc = "disable spellcheck in terminal buffers",
    group = augroup("disable_spell"),
    pattern = "*",
    command = "setlocal nospell",
  })
end

-- Set relative number in normal mode
if group.autocommands.number then
  cmd({ "VimEnter", "InsertLeave" }, {
    desc = "set relativenumber",
    group = augroup("set_relativenumber"),
    pattern = "*",
    command = "set relativenumber",
  })
  cmd({ "InsertEnter" }, {
    desc = "set number",
    group = augroup("set_number"),
    pattern = "*",
    command = "set number norelativenumber",
  })
end

-- Disable creating new comment on next line on enter
if group.autocommands.comment then
  cmd({ "FileType" }, {
    desc = "disable autocomment next line on enter",
    group = augroup("disable_autocomment_next_line"),
    pattern = "*",
    command = "setlocal formatoptions-=r",
  })
end

-- Synchronize terminal background with neovim
if group.autocommands.syncbackground then
  cmd({ "UIEnter", "ColorScheme" }, {
    desc = "sync terminal background with neovim",
    group = augroup("sync_background"),
    pattern = "*",
    callback = function()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
      if not normal.bg then return end
      io.write(string.format("\027]11;#%06x\027\\", normal.bg))
    end,
  })

  cmd("UILeave", {
    desc = "reset background",
    group = augroup("reset_background"),
    pattern = "*",
    callback = function() io.write("\027]111\027\\") end,
  })
end

-- Sets cwd to git root
if group.autocommands.autoroot then
  cmd("BufEnter", {
    group = augroup("auto_root"),
    callback = require("core.utils.utils").set_root,
  })
end

-- No line numbers in terminal buffers
if group.autocommands.term_line_numbers then
  cmd({ "FileType" }, {
    desc = "disable line numbers for terminal filetype",
    group = augroup("disable_term_line_numbers_ft"),
    pattern = "terminal",
    command = "setlocal nonumber norelativenumber",
  })
end

-- Format on save using native LSP formatting
if group.autocommands.autoformat then
  cmd("BufWritePre", {
    group = augroup("LspFormatting", { clear = true }),
    callback = function(args)
      vim.lsp.buf.format({
        bufnr = args.buf,
        async = false,
        timeout_ms = 10000,
      })
    end,
  })
end

-- Setup native auto-save
if group.autocommands.autosave then
  local timers = {}
  local function save_buf(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modified then
      vim.api.nvim_buf_call(bufnr, function()
        if group.autocommands.auto_format_on_autosave then
          pcall(vim.lsp.buf.format, { bufnr = bufnr, async = false })
        end
        vim.cmd("silent! write")
      end)
    end
  end

  -- Defer saving on TextChanged/InsertLeave
  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = augroup("AutosaveGroup", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      if
        vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].modified
        and not vim.bo[bufnr].readonly
        and vim.fn.empty(vim.bo[bufnr].buftype) == 1
      then
        if timers[bufnr] then timers[bufnr]:stop() end
        timers[bufnr] = vim.defer_fn(function()
          save_buf(bufnr)
          timers[bufnr] = nil
        end, require("defaults").plugin_settings.autosave_delay or 1000)
      end
    end,
  })

  -- Save immediately on BufLeave/FocusLost
  vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
    group = augroup("AutosaveGroupImmediate", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      if
        vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].modified
        and not vim.bo[bufnr].readonly
        and vim.fn.empty(vim.bo[bufnr].buftype) == 1
      then
        if timers[bufnr] then
          timers[bufnr]:stop()
          timers[bufnr] = nil
        end
        save_buf(bufnr)
      end
    end,
  })
end

-- Setup native session auto-save on exit
if group.autocommands.persistence then
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = augroup("SessionAutosave", { clear = true }),
    callback = function() require("core.utils.session").save_session() end,
  })
end

-- Setup native document highlight (LSP reference highlight)
if group.autocommands.illuminate then
  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup("LspDocumentHighlight", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client:supports_method("textDocument/documentHighlight") then
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = args.buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = args.buf,
          callback = vim.lsp.buf.clear_references,
        })
      end
    end,
  })
end

-- Lazy loading event triggered autocommands

-- 1. LSP stack lazy loading
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = augroup("LazyLoadLSP", { clear = true }),
  once = true,
  callback = function()
    local lsp_plugins = {
      "nvim-lspconfig",
      "mason.nvim",
      "mason-lspconfig.nvim",
      "none-ls.nvim",
      "mason-null-ls.nvim",
      "workspace-diagnostics.nvim",
      "SchemaStore.nvim",
      "async.nvim",
      "refactoring.nvim",
      "lazydev.nvim",
    }
    for _, p in ipairs(lsp_plugins) do
      vim.cmd("packadd " .. p)
    end
    require("core.configs.lazydev")
    require("core.configs.lsp")
    -- Re-trigger FileType to attach LSP to the current buffer
    vim.cmd("silent! doautocmd FileType")
  end,
})

-- 2. Blink Completion lazy loading
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  group = augroup("LazyLoadBlink", { clear = true }),
  once = true,
  callback = function()
    vim.cmd("packadd friendly-snippets")
    vim.cmd("packadd blink.cmp")
    require("core.configs.blink")
  end,
})

-- 3. Markdown rendering lazy loading
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("LazyLoadMarkdown", { clear = true }),
  pattern = "markdown",
  once = true,
  callback = function()
    vim.cmd("packadd markdown.nvim")
    vim.cmd("packadd markview.nvim")
    require("core.configs.markdown")
  end,
})

-- 4. Todo Comments lazy loading
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = augroup("LazyLoadTodo", { clear = true }),
  once = true,
  callback = function()
    vim.cmd("packadd todo-comments.nvim")
    require("core.configs.todo")
  end,
})

-- 5. Editor editing helper plugins lazy loading (gitsigns, highlight-colors, indent-blankline)
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = augroup("LazyLoadEditHelpers", { clear = true }),
  once = true,
  callback = function()
    vim.cmd("packadd gitsigns.nvim")
    vim.cmd("packadd nvim-highlight-colors")
    vim.cmd("packadd indent-blankline.nvim")
    require("core.configs.gitsigns")
    require("core.configs.highlight_colors")
    require("core.configs.indent_blankline")
  end,
})
