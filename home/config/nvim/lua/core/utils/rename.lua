-- Custom LSP rename implementation with better UI and error handling
local M = {}

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------

-- Get buffers that are currently listed (in the buffer list)
local function get_initially_open_buffers()
  local open = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) then open[bufnr] = true end
  end
  return open
end

-- Format and save a buffer if it is valid and has a name
local function format_and_save_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return end

  if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
    local ok, err = pcall(function()
      vim.api.nvim_buf_call(bufnr, function()
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
        vim.cmd("silent! write")
      end)
    end)
    if not ok then vim.notify(string.format("Failed to save %s: %s", name, err), "warn") end
  end
end

-- Collect rename edits and build a notification message
local function collect_edits(result)
  local entries = {}
  local modified = {}
  local notif_lines = {}
  local files, updates = 0, 0

  local cwd_len = #vim.uv.cwd() + 2

  local function handle(uri, edits)
    files = files + 1
    local bufnr = vim.uri_to_bufnr(uri)
    table.insert(modified, bufnr)

    for _, edit in ipairs(edits) do
      local start = edit.range.start
      local lnum = start.line + 1
      local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
      table.insert(entries, {
        bufnr = bufnr,
        lnum = lnum,
        col = start.character + 1,
        text = line,
      })
    end

    updates = updates + #edits
    local short = string.sub(vim.uri_to_fname(uri), cwd_len)
    table.insert(notif_lines, string.format("\t- %d in %s", #edits, short))
  end

  if result.documentChanges then
    for _, doc in ipairs(result.documentChanges) do
      handle(doc.textDocument.uri, doc.edits)
    end
  end

  if result.changes then
    for uri, edits in pairs(result.changes) do
      handle(uri, edits)
    end
  end

  -- Build notification message
  local summary
  if files > 1 then
    table.insert(
      notif_lines,
      1,
      string.format("made %d change%s in %d files", updates, updates > 1 and "s" or "", files)
    )
    summary = table.concat(notif_lines, "\n")
  else
    local base = notif_lines[1]:sub(4)
    local iloc = base:find("in") or 1
    summary = table.concat({
      base:sub(1, iloc - 1),
      string.format("change%s ", updates > 1 and "s" or ""),
      base:sub(iloc),
    }, "")
  end

  return summary, modified
end

---------------------------------------------------------------------
-- Main rename function
---------------------------------------------------------------------

local function do_rename(param)
  local initially_open = get_initially_open_buffers()

  vim.lsp.buf_request(0, "textDocument/rename", param, function(err, result, ctx, config)
    if err then
      vim.notify(
        string.format("LSP error during rename: %s", vim.inspect(err)),
        "error",
        { title = "[LSP] rename", timeout = 3000 }
      )
      return
    end

    if not result then
      vim.notify(
        string.format("No result from LSP server for rename: %s -> %s", param.old, param.newName),
        "warn",
        { title = "[LSP] rename", timeout = 2000 }
      )
      return
    end

    if not result.documentChanges and not result.changes then
      vim.notify(
        string.format("No changes returned for rename: %s -> %s", param.old, param.newName),
        "warn",
        { title = "[LSP] rename", timeout = 2000 }
      )
      return
    end

    -- Setup autocommand to prevent bufferline flashing for newly opened buffers
    local group = vim.api.nvim_create_augroup("LspRenameSilence", { clear = true })
    vim.api.nvim_create_autocmd({ "BufAdd", "BufCreate" }, {
      group = group,
      callback = function(args)
        if not initially_open[args.buf] then
          pcall(vim.api.nvim_set_option_value, "buflisted", false, { buf = args.buf })
          pcall(vim.api.nvim_set_option_value, "bufhidden", "hide", { buf = args.buf })
        end
      end,
    })

    local apply_ok, apply_err = pcall(
      function() vim.lsp.handlers["textDocument/rename"](err, result, ctx, config) end
    )

    if not apply_ok then
      pcall(vim.api.nvim_clear_autocmds, { group = group })
      vim.notify(
        string.format("Failed to apply edits: %s", apply_err),
        "error",
        { title = "[LSP] rename", timeout = 3000 }
      )
      return
    end

    local message, modified_buffers = collect_edits(result)
    local truncate = require("core.utils.utils").truncate_message
    message = truncate(message, 500)

    vim.notify(message, "info", {
      title = string.format("[LSP] rename: %s -> %s", param.old, param.newName),
      timeout = 2500,
    })

    vim.schedule(function()
      for _, bufnr in ipairs(modified_buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          format_and_save_buffer(bufnr)
          if not initially_open[bufnr] then
            pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
          end
        end
      end
      pcall(vim.api.nvim_clear_autocmds, { group = group })
    end)
  end)
end

---------------------------------------------------------------------
-- Public entry point
---------------------------------------------------------------------

function M.rename()
  local param = vim.lsp.util.make_position_params(0, "utf-8")
  param.old = vim.fn.expand("<cword>")

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP client attached", "error", { title = "[LSP] rename" })
    return
  end

  local supports_rename = false
  for _, client in ipairs(clients) do
    if client.server_capabilities.renameProvider then
      supports_rename = true
      break
    end
  end

  if not supports_rename then
    vim.notify("No LSP client supports rename", "error", { title = "[LSP] rename" })
    return
  end

  vim.ui.input({ prompt = "rename to> ", default = param.old }, function(input)
    if input == nil then
      vim.notify("aborted", "warn", { title = "[LSP] rename", render = "compact" })
      return
    end

    if input == param.old then
      vim.notify("name unchanged", "warn", { title = "[LSP] rename", render = "compact" })
      return
    end

    param.newName = input
    do_rename(param)
  end)
end

return M
