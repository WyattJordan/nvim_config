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
  enabled = true,
  opts = {
    -- This override works but not enabling it as all notes should use a template
    -- notes not using a template will be in the root folder (ugly)
    -- notes_subdir = "notes",
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
    follow_url_func = function(url)
      vim.fn.jobstart({ "open", url }) -- Mac OS
    end,
    note_id_func = create_note_id_func("raw"),
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNewFromTemplate<cr>", desc = "New Templated note" },
    { "<leader>oN", "<cmd>ObsidianNew<cr>", desc = "New Raw note" },
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open Obsidian App" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
    { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Open Today's note" },
    { "<leader>oT", "<cmd>ObsidianTomorrow<cr>", desc = "Open Tomorrow's note" },
    { "<leader>ov", "<cmd>ObsidianTags<cr>", desc = "Open Tags" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Open yesterday's note" },
    { "<leader>om", "<cmd>ObsidianTemplate<cr>", desc = "Insert template" },
    { "<leader>ol", "<cmd>ObsidianLink<cr>", desc = "Create/Edit link" },
    { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follow link" },
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch" },
    { "<leader>oe", "<cmd>ObsidianExtractNote<cr>", desc = "Extract Note" },
    { "<leader>oi", "<cmd>ObsidianPasteImg<cr>", desc = "Paste Image" },
    { "<leader>oc", ":e ~/.config/nvim/lua/plugins/obsidian.lua<CR>", desc = "Open Obsidian config" },
  },
}
