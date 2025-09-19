return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = false, -- Still respect .gitignore
        always_show = { ".gitignore" },
        -- Custom list of patterns to hide
        exclude_filetype = {},
        exclude_pattern = {
          -- "build",
          "dist",
          "target",
        },
      },
    },
  },
}
