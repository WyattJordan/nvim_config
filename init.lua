-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.opt.wrap = true

-- make window splits more obvious
vim.opt.fillchars:append({ vert = "┃", horiz = "━" })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#ff0000", bg = "NONE" }) -- Set your desired color

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.b.autoformat = false
  end,
})

-- Nvim as godot editor with server pipe file
-- copied from: https://simondalvai.org/blog/godot-neovim/
local paths_to_check = { "/", "/../" }
local is_godot_project = false
local godot_project_path = ""
local cwd = vim.fn.getcwd()

-- iterate over paths and check
for key, value in pairs(paths_to_check) do
  if vim.uv.fs_stat(cwd .. value .. "project.godot") then
    is_godot_project = true
    godot_project_path = cwd .. value
    break
  end
end

-- check if server is already running in godot project path
local is_server_running = vim.uv.fs_stat(godot_project_path .. "/server.pipe")
-- start server, if not already running
if is_godot_project and not is_server_running then
  vim.fn.serverstart(godot_project_path .. "/server.pipe")

  -- setup lsp
  -- lspconfig.gdscript.setup {}
end
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.v.servername then
      vim.fn.system("osascript -e 'tell application \"kitty\" to activate'")
    end
  end,
})
-- vim.fn.serverstart("/tmp/server.pipe")
