--[[
================================================================================
DAP SIGNS OVERRIDE - FORCE RED CIRCLE BREAKPOINTS
================================================================================
This plugin forcefully overrides LazyVim's DAP sign configuration.
NOTE: lazy.nvim only runs the LAST `config` defined for nvim-dap, and this file
is the last one imported (plugins/dap/* load alphabetically). The `config`
functions in init.lua, logger.lua and python.lua, and LazyVim's dap.core
extra, do NOT run. That's why LazyVim's base setup is replicated here.
================================================================================
--]]

return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  priority = 1, -- Muy baja prioridad = carga al final

  config = function()
    -- Base de LazyVim (extras/dap/core.lua), que este config sustituye
    if LazyVim.has("mason-nvim-dap.nvim") then
      require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
    end
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    local vscode = require("dap.ext.vscode")
    local json = require("plenary.json")
    vscode.json_decode = function(str)
      return vim.json.decode(json.json_strip_comments(str))
    end

    -- Esperar a que todo esté cargado
    vim.schedule(function()
      -- Definir los signos con círculo rojo
      local signs = {
        DapBreakpoint = { text = "●", texthl = "DapBreakpoint" },
        DapBreakpointCondition = { text = "●", texthl = "DapBreakpoint" },
        DapBreakpointRejected = { text = "●", texthl = "DapBreakpoint" },
        DapLogPoint = { text = "●", texthl = "DapLogPoint" },
        DapStopped = { text = "➜", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedLine" },
      }

      -- Aplicar los signos
      for name, sign in pairs(signs) do
        vim.fn.sign_define(name, sign)
      end

      -- Colores
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff0000", bold = true })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })

      -- Volver a aplicar después de un delay
      vim.defer_fn(function()
        for name, sign in pairs(signs) do
          vim.fn.sign_define(name, sign)
        end
      end, 500)

      -- Autocomando al cambiar colorscheme
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff0000", bold = true })
          vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
          vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
          for name, sign in pairs(signs) do
            vim.fn.sign_define(name, sign)
          end
        end,
      })
    end)
  end,
}
