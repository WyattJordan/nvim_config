local is_server = vim.fn.filereadable(vim.fn.expand("~/.config/nvim/.is_server")) == 1

return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "epwalsh/obsidian.nvim", enabled = not is_server },
}
--[[return {
  { "folke/persistence.nvim", enabled = false },
  { "karb94/neoscroll.nvim", enabled = false },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  --[[
  --{ "nvim-mini/mini.animate", enabled = false },
  { "nvim-treesitter/nvim-treesitter", enabled = false },
}
  --]]
