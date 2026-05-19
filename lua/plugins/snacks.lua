return {
  "folke/snacks.nvim",
  opts = {
    -- image = {
    --   enabled = true,
    --   backend = "image.nvim",
    --   -- from https://github.com/obsidian-nvim/obsidian.nvim/wiki/Images
    --   resolve = function(path, src)
    --     if require("obsidian.api").path_is_note(path) then
    --       return require("obsidian.api").resolve_image_path(src)
    --     end
    --     return src
    --   end,
    -- },
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
