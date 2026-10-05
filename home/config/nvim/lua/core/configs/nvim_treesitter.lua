-- nvim-treesitter (main) is a parser installer and query provider.
-- Highlighting and indent use Neovim native treesitter, started per-buffer.
-- Limit parallel compiler jobs on smaller hosts such as the NAS.
require("nvim-treesitter").install(
  require("defaults").ensure_installed.treesitter,
  { max_jobs = 2 }
)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf)
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
