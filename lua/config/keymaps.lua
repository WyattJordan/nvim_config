-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

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
