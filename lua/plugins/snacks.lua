return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true, -- for hidden files
      ignored = true, -- for .gitignore files
    },
    explorer = {},
  },
  keys = {
    -- Top Pickers & Explorer
    {
      "<leader>fh",
      function()
        -- Snacks.picker.files({ cwd = vim.fn.stdpath("/Users/wyattjor/") })
        Snacks.picker.files({ cwd = "/Users/wyattjor/" })
      end,
      desc = "Find Home File",
    },
  },
}
