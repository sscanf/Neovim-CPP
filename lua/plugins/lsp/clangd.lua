--[[
  Custom clangd configuration
  Uses system-installed clangd instead of Mason (for ARM64/aarch64 compatibility)

  Install clangd via system package manager:
    sudo apt install clangd
--]]

return {
  -- Disable Mason installation for clangd
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "clangd"
      end, {}),
    },
  },

  -- Configure clangd to use system binary
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          -- Use system clangd (must be in PATH)
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          -- Don't install via Mason
          mason = false,
        },
      },
    },
  },
}
