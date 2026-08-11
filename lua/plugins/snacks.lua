-- Resolve a git root for the git pickers.
--
-- Snacks' pickers call ctx:git_root(), which is
-- `Snacks.git.get_root(cwd) or cwd`. Launching nvim from ~/ws (not a repo, and
-- with no repo above it) makes that fall back to ~/ws itself, so it shells out
-- to `git status`/`git diff` in a non-repo and every command fails with
-- "Command failed". Prefer the current buffer's repo, since in a Brazil
-- workspace each package under src/ is its own repo.
local function git_root()
  local buf = vim.api.nvim_buf_get_name(0)
  -- Only trust a real file on disk; skip pickers, terminals, etc.
  if buf ~= "" and vim.uv.fs_stat(buf) then
    local root = Snacks.git.get_root(buf)
    if root then
      return root
    end
  end
  return Snacks.git.get_root(vim.fn.getcwd())
end

-- Run a git picker against the buffer's repo, or explain why it can't.
local function git_picker(name, opts)
  return function()
    local root = git_root()
    if not root then
      Snacks.notify.warn(
        ("No git repository for %s.\nOpen a file inside a repo first."):format(
          vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
        ),
        { title = "Snacks Picker" }
      )
      return
    end
    Snacks.picker[name](vim.tbl_extend("force", { cwd = root }, opts or {}))
  end
end

return {
  "folke/snacks.nvim",
  keys = {
    -- Override the LazyVim defaults so they resolve the repo from the buffer.
    { "<leader>gs", git_picker("git_status"), desc = "Git Status" },
    { "<leader>gd", git_picker("git_diff"), desc = "Git Diff (hunks)" },
    { "<leader>gD", git_picker("git_diff", { base = "origin", group = true }), desc = "Git Diff (origin)" },
    { "<leader>gl", git_picker("git_log"), desc = "Git Log" },
    { "<leader>gb", git_picker("git_branches"), desc = "Git Branches" },
    { "<leader>gS", git_picker("git_stash"), desc = "Git Stash" },
    { "<leader>fg", git_picker("git_files"), desc = "Find Files (git-files)" },
    {
      "<leader>fh",
      function()
        Snacks.picker.files({ cwd = vim.fn.expand("~") })
      end,
      desc = "Find Home File",
    },
  },
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
}
