return {
  "rmagatti/auto-session",
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  -- Add your keymaps here
  keys = {
    -- Your new keymaps go here, for example:
    { "<leader>qs", "<cmd>SessionSave<cr>", desc = "Save Session" },
    { "<leader>qr", "<cmd>SessionRestore<cr>", desc = "Restore Session" },
    { "<leader>qd", "<cmd>SessionDelete<cr>", desc = "Delete Session" },
    { "<leader>ql", "<cmd>SessionSearch<cr>", desc = "Search Sessions" },

    -- Return an empty table to clear all default keymaps for the plugin
    -- keys = function() return {} end,
  },
  opts = {
    auto_create = false,
    suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    -- log_level = 'debug',
  },
}
