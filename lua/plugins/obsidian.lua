--[[
                     E471: Argument required
                         Failed to run `config` for obsidian.nvim

...share/nvim/lazy/obsidian.nvim/lua/obsidian/workspace.lua:208: ENOENT: no such file or directory

# stacktrace:
  - /obsidian.nvim/lua/obsidian/workspace.lua:208 _in_ **setup**
  - /obsidian.nvim/lua/obsidian/init.lua:62 _in_ **setup**
  - ~/.config/nvim/lua/config/lazy.lua:17
  - ~/.config/nvim/init.lua:2
                      legacy_commands is deprecated, use move from commands like `ObsidianBacklinks` to `Obsidian backlinks`
and set `opts.legacy_commands` to false to get rid of this warning.
see https://github.com/obsidian-nvim/obsidian.nvim/wiki/Commands for details.
     instead.
Feature will be removed in obsidian.nvim 4.0
                      follow_url_func is deprecated, use vim.ui.open, see https://github.com/obsidian-nvim/obsidian.nvim/wiki/Attachment instead.
Feature will be removed in obsidian.nvim 3.16

--]]

local function create_note_id_func(template_name)
  return function(title)
    local suffix = ""
    if title ~= nil then
      suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    else
      for _ = 1, 4 do
        suffix = suffix .. string.char(math.random(65, 90))
      end
    end

    local current_date = os.date("%Y%b%d")
    -- print("note_id_func called with title:", title, "template:", template_name)
    return current_date .. "-" .. template_name .. "-" .. suffix
  end
end

local vault_dir = "~/personal/journal/"
local function get_template_files()
  local templates = {}
  local template_dir = vim.fn.expand(vault_dir .. "templates")
  -- Get all .md files in the template directory
  local files = vim.fn.glob(template_dir .. "/*.md", false, true)

  for _, file in ipairs(files) do
    -- Extract just the filename without path and extension
    local template_name = vim.fn.fnamemodify(file, ":t:r")
    table.insert(templates, template_name)
  end
  return templates
end

-- Replace your static all_templates with:
local all_templates = get_template_files()
local special_templates = {
  issues = true,
  mtgs = true,
  learn = true,
}

-- Generate the customizations table
local template_folders_custom = {}
for _, name in ipairs(all_templates) do
  if special_templates[name] ~= nil then
    template_folders_custom[name] = { notes_subdir = name }
  else
    template_folders_custom[name] = { notes_subdir = "docs" }
  end
  template_folders_custom[name]["note_id_func"] = create_note_id_func(name)
end

-- debugging generation
--print("template custom is:")
--print(vim.inspect(template_folders_custom))
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- ft = "markdown",
  lazy = false,
  enabled = vim.fn.filereadable(vim.fn.expand("$HOME/.config/nvim/.is_server")) == 0,
  opts = {
    -- This override works but not enabling it as all notes should use a template
    -- notes not using a template will be in the root folder (ugly)
    notes_subdir = "notes",
    workspaces = {
      {
        name = "personal",
        path = vault_dir,
      },
    },
    daily_notes = {
      folder = "daily", -- relative to vault root
      date_format = "%Y-%m-%d", -- optional, but helps
      alias_format = "%A, %B %-d, %Y", -- optional, but helps
      template = "daily.md",
    },
    templates = {
      folder = "templates",
      customizations = template_folders_custom,
      --[[customizations = {
        issues = {
          notes_subdir = "issues",
        }, 
      }, --]]
    },
    legacy_commands = false,
    -- follow_url_func = function(url)
    --   vim.fn.jobstart({ "open", url }) -- Mac OS
    -- end,
    note_id_func = create_note_id_func("raw"),
  },
  keys = {
    { "<leader>oN", "<cmd>Obsidian new_from_template<cr>", desc = "New Templated note" },
    { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New Raw note" },
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open Obsidian App" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search Obsidian" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks" },
    { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Open Today's note" },
    { "<leader>oT", "<cmd>Obsidian tomorrow<cr>", desc = "Open Tomorrow's note" },
    { "<leader>ov", "<cmd>Obsidian tags<cr>", desc = "Open Tags" },
    { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Open yesterday's note" },
    { "<leader>om", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    { "<leader>ol", "<cmd>Obsidian link<cr>", desc = "Create/Edit link" },
    { "<leader>of", "<cmd>Obsidian follow<cr>", desc = "Follow link" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
    { "<leader>oe", "<cmd>Obsidian extract_note<cr>", desc = "Extract Note" },
    { "<leader>oi", "<cmd>Obsidian paste_img<cr>", desc = "Paste Image" },
    { "<leader>oc", ":e ~/.config/nvim/lua/plugins/obsidian.lua<CR>", desc = "Open Obsidian config" },
  },
}
