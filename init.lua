-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.opt.wrap = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.b.autoformat = false
  end,
})
