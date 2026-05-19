return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Add your desired parsers to the existing list
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "rust",
          "markdown",
          "markdown_inline",
        })
      end
    end,
  },
}
