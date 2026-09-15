-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy buffer path components to the system clipboard
vim.keymap.set("n", "<leader>yd", function()
  local dir = vim.fn.expand("%:p:h")
  vim.fn.setreg("+", dir)
  vim.notify(dir, vim.log.levels.INFO, { title = "Copied directory" })
end, { desc = "Copy directory to clipboard" })

vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied path" })
end, { desc = "Copy full path to clipboard" })

vim.keymap.set("n", "<leader>yf", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  vim.notify(name, vim.log.levels.INFO, { title = "Copied filename" })
end, { desc = "Copy filename to clipboard" })

-- Open a code.amazon.com link to the current line (package = git repo, branch = mainline)
vim.keymap.set("n", "<leader>yl", function()
  local root = vim.fs.root(0, ".git")
  if not root then
    vim.notify("Not inside a git repo", vim.log.levels.WARN, { title = "code.amazon link" })
    return
  end
  local pkg = vim.fs.basename(root)
  local rel = vim.fn.expand("%:p"):sub(#root + 2) -- strip root dir and its trailing slash
  local url = string.format("https://code.amazon.com/packages/%s/blobs/mainline/--/%s#L%d", pkg, rel, vim.fn.line("."))
  vim.fn.setreg("+", url)
  vim.ui.open(url)
  vim.notify(url, vim.log.levels.INFO, { title = "Opened code.amazon link" })
end, { desc = "Open code.amazon link in browser" })

-- Yank the current line without newline (important for grabbing CLI cmds)
vim.keymap.set("n", "<leader>Y", function()
  local line = vim.api.nvim_get_current_line()
  vim.fn.setreg("+", line) -- Saves to the system clipboard (+)
end, { desc = "Yank line text without newline" })

vim.api.nvim_create_user_command("PasteHyperlinksAsMarkdown", function()
  local cmd = [[osascript -e 'the clipboard as «class HTML»' | ]]
    .. [[perl -ne 'print chr foreach unpack("C*",pack("H*",substr($_,11,-3)))' | ]]
    .. [[perl -0777 -pe ']]
    .. [[s/<a\s[^>]*?href="([^"]*)"[^>]*>(.*?)<\/a>/[$2]($1)/gs;]]
    .. [[s/<br\s*\/?>/\n/gi;]]
    .. [[s/<\/(?:div|p|li|tr)>/\n/gi;]]
    .. [[s/<[^>]+>//g;]]
    .. [[']]
  local result = vim.fn.system(cmd)
  vim.api.nvim_put(vim.split(result, "\n"), "c", true, true)
end, {})

-- local harpoon = require("harpoon")
--
-- -- REQUIRED
-- harpoon:setup()
-- -- REQUIRED
--
-- vim.keymap.set("n", "<leader>a", function()
--   harpoon:list():add()
-- end)
-- vim.keymap.set("n", "<C-e>", function()
--   harpoon.ui:toggle_quick_menu(harpoon:list())
-- end)
--
-- vim.keymap.set("n", "<C-h>", function()
--   harpoon:list():select(1)
-- end)
-- vim.keymap.set("n", "<C-t>", function()
--   harpoon:list():select(2)
-- end)
-- vim.keymap.set("n", "<C-n>", function()
--   harpoon:list():select(3)
-- end)
-- vim.keymap.set("n", "<C-s>", function()
--   harpoon:list():select(4)
-- end)
--
-- -- Toggle previous & next buffers stored within Harpoon list
-- vim.keymap.set("n", "<C-S-P>", function()
--   harpoon:list():prev()
-- end)
-- vim.keymap.set("n", "<C-S-N>", function()
--   harpoon:list():next()
-- end)
