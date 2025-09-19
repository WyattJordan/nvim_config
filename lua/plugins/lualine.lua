--[[
local git_icon2 = "󰊢"
""
--]]
--[[
local function git_icon_path()
  local filepath = vim.fn.expand("%:p")
  local git_icon = "󰊢" -- Nerd Font git logo
 local sep = "/"
  local path_parts = {}
  for part in string.gmatch(filepath, "[^" .. sep .. "]+") do
    table.insert(path_parts, part)
  end
  local display = ""
  local path_so_far = (filepath:sub(1, 1) == sep) and sep or ""
  for i, part in ipairs(path_parts) do
    path_so_far = path_so_far .. part
    -- Check for .git directory in path_so_far
    local git_path = path_so_far .. sep .. ".git"
    if vim.fn.isdirectory(git_path) == 1 then
      display = display .. git_icon .. part
    else
      display = display .. part
    end
    if i < #path_parts then
      display = display .. sep
      path_so_far = path_so_far .. sep
    end
  end
  return display
end
--]]

--[[local function git_icon_path()
  local git_icon = "󰊢" -- Nerd Font git logo
  local filepath = vim.fn.expand("%:p")
  local sep = "/"
  local path_parts = {}
  for part in string.gmatch(filepath, "[^" .. sep .. "]+") do
    table.insert(path_parts, part)
  end
  vim.api.nvim_set_hl(0, "LualineGitIcon", { fg = "#ffdd33", bold = true }) -- can be anywhere before return

  local display = ""
  local path_so_far = (filepath:sub(1, 1) == sep) and sep or ""
  for i, part in ipairs(path_parts) do
    path_so_far = path_so_far .. part
    local git_path = path_so_far .. sep .. ".git"
    if vim.fn.isdirectory(git_path) == 1 then
      display = display .. " " .. "%#LualineGitIcon#" .. git_icon .. "%*" .. " " .. part
    else
      display = display .. part
    end
    if i < #path_parts then
      display = display .. sep
      path_so_far = path_so_far .. sep
    end
  end
  return display
end
--]]
local function git_icon_path()
  local git_icon = "󰊢"
  local home = os.getenv("HOME") -- /Users/<username>
  local filepath = vim.fn.expand("%:p")
  local sep = "/"

  -- Replace home dir with ~
  if filepath:sub(1, #home) == home then
    filepath = "~" .. filepath:sub(#home + 1)
  end

  local path_parts = {}
  for part in string.gmatch(filepath, "[^" .. sep .. "]+") do
    table.insert(path_parts, part)
  end
  vim.api.nvim_set_hl(0, "LualineGitIcon", { fg = "#ffdd33", bold = true })

  local display = ""
  -- Build the absolute path for git detection (not the display one)
  local path_so_far = (filepath:sub(1, 1) == "~") and home .. sep or ((filepath:sub(1, 1) == sep) and sep or "")
  for i, part in ipairs(path_parts) do
    -- For display, use "~" if first part is "~"
    local display_part = part
    if i == 1 and part == "~" then
      path_so_far = home .. sep
    else
      path_so_far = path_so_far .. part
    end

    local git_path = path_so_far .. sep .. ".git"
    if vim.fn.isdirectory(git_path) == 1 then
      display = display .. " " .. "%#LualineGitIcon#" .. git_icon .. " " .. part .. "%*"
    else
      display = display .. part
    end
    if i < #path_parts then
      display = display .. sep
      path_so_far = path_so_far .. sep
    end
  end
  return display
end
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        tabline = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            git_icon_path,
          },
          lualine_x = { "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        sections = {}, -- disables statusline at the bottom
        options = {
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
          always_show_tabline = true,
        },
      }
    end,
  },
}
