--[[
================================================================================
AUTO SESSION MANAGEMENT
================================================================================
Automatically saves and restores Neovim sessions.
Features:
  - Automatic session save/restore per project
  - Session lens for browsing and loading sessions
  - Excludes specific directories (home, downloads, root)
  - Preserves buffers, windows, and tab layouts
Plugin: rmagatti/auto-session
================================================================================
--]]

return {
  "rmagatti/auto-session",
  config = function()
    local function fix_loaded_buffers()
      pcall(function()
        require("lazy").load({ plugins = { "nvim-treesitter" } })
      end)
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
          local ft = vim.bo[bufnr].filetype
          if ft == "" then
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name ~= "" then
              local detected = vim.filetype.match({ buf = bufnr, filename = name })
              if detected then
                vim.bo[bufnr].filetype = detected
              end
            end
          end
        end
      end
    end

    require("auto-session").setup({
      auto_session_suppres_dirs = { "~/", "~/projects/", "~/Downloads", "/" },
      session_lens = {
        buftypes_to_ignore = {},
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
      },
      post_restore_cmds = {
        function()
          vim.schedule(fix_loaded_buffers)
        end,
      },
    })

    -- auto-session restaura el buffer activo sin disparar el evento FileType,
    -- así que su filetype queda vacío y ni treesitter ni el syntax clásico se
    -- enganchan. Detectamos el filetype manualmente con vim.filetype.match()
    -- y lo asignamos; al asignarlo Neovim dispara FileType, que es lo que
    -- LazyVim usa para llamar vim.treesitter.start(buf).
    vim.api.nvim_create_autocmd("SessionLoadPost", {
      group = vim.api.nvim_create_augroup("AutoSessionTreesitterFix", { clear = true }),
      callback = function()
        vim.schedule(fix_loaded_buffers)
      end,
    })
  end,
}
