return {
  {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
          clangd = {
            cmd = {
              "clangd",
              "--query-driver=*/arm-none-eabi-*",
            },
          },
        },
      setup = {
        clangd = function()
          local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
          if bemol_dir then
            local file = io.open(bemol_dir .. "/ws_root_folders", "r")
            if file then
              for line in file:lines() do
                vim.lsp.buf.add_workspace_folder(line)
              end
              file:close()
            end
          end
        end,
      },
    },
  },
}

-- require("mason-lspconfig").setup({
--  handlers = {
--   function(server_name)
--    local server = servers[server_name] or {}
--    require("lspconfig")[server_name].setup({
--     cmd = server.cmd,
--     settings = server.settings,
--     filetypes = server.filetypes,
--     capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {}),
--    })
--   end,
--   jdtls = function()
--    require("lspconfig").jdtls.setup({
--     on_attach = function()
--      local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
--      local ws_folders_lsp = {}
--      if bemol_dir then
--       local file = io.open(bemol_dir .. "/ws_root_folders", "r")
--       if file then
--        for line in file:lines() do
--         table.insert(ws_folders_lsp, line)
--        end
--        file:close()
--       end
--      end
--      for _, line in ipairs(ws_folders_lsp) do
--       vim.lsp.buf.add_workspace_folder(line)
--      end
--     end,
--     cmd = {
--      "jdtls",
--      "--jvm-arg=-javaagent:" .. vim.fn.expand("$MASON/share/jdtls/lombok.jar"),
--     },
--    })
--   end,
--  },
-- })
