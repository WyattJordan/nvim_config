return {
  -- Keep mason from installing its prebuilt tree-sitter-cli on this server.
  --
  -- The prebuilt binary needs a modern glibc; AL2 has 2.26, so it can't run and
  -- every parser build fails with "GLIBC_2.39 not found". ~/.dotfiles/scripts/
  -- treesitter_install.sh builds the CLI from source into ~/.local/bin instead.
  --
  -- LazyVim's ensure_treesitter_cli() only reaches for mason when `tree-sitter`
  -- isn't on PATH, so normally the source build is enough. This is the backstop
  -- for when a stale mason copy is present anyway: mason defaults to
  -- PATH = "prepend", which puts its bin dir in front of ~/.local/bin and lets
  -- the broken binary win. "append" flips that so the source build takes
  -- precedence, while other mason tools (clangd, stylua, ...) still resolve.
  -- Guarded by .is_server so laptops keep the default behavior.
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/.is_server") then
        opts.PATH = "append"
      end
    end,
  },
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
