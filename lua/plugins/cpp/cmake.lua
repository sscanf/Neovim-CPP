--[[
================================================================================
CMAKE TOOLS CONFIGURATION
================================================================================
Integrates CMake build system with Neovim.
Features:
  - Parallel builds (uses all available CPU cores)
  - CMakeDeploy command for deployment
  - Automatic deployment before remote debugging
  - Build management (CMakeBuild, CMakeDebug, etc.)
Plugin: Civitasv/cmake-tools.nvim
================================================================================
--]]

return {
  "Civitasv/cmake-tools.nvim",
  commit = "d6fa30479c5f392f6f80b4b2e542f91155b289a8",
  config = function()
    -- Configure CMake tools with parallel builds
    require("cmake-tools").setup({
      cmake_build_args = { "-j", tostring(vim.loop.cpu_info() and #vim.loop.cpu_info() or 4) },
      cmake_executor = {
        name = "quickfix",
        opts = {
          position = "botright", -- Abre ocupando todo el ancho inferior
          size = 10,
        },
      },
    })

    -- Create CMakeDeploy command
    vim.api.nvim_create_user_command("CMakeDeploy", function(opts)
      -- Si se pasa el argumento 'build', compilar primero
      if opts.args == "build" then
        vim.notify("🔨 Compilando proyecto...", vim.log.levels.INFO)
        vim.cmd("CMakeBuild")
        vim.notify("⏳ Espera a que termine la compilación y ejecuta :CMakeDeploy de nuevo", vim.log.levels.INFO)
        return
      end

      -- Hacer deploy remoto
      if _G.deploy_remote_program then
        _G.deploy_remote_program()
      else
        vim.notify("❌ Función de deploy no disponible. ¿Cargaste remote.lua?", vim.log.levels.ERROR)
      end
    end, { nargs = "?", desc = "Desplegar a sistema remoto (usa 'build' para compilar primero)" })

    -- Automatically run CMakeDeploy before remote debugging
    -- This listener triggers when attaching to a debug session
    local dap = require("dap")
    dap.listeners.before.attach["cmake_deploy"] = function(session, body)
      -- Only for remote debugging (adjust condition based on your configuration)
      if body and body.name and body.name:lower():find("remote") then
        vim.cmd("CMakeDeploy")
      end
    end

    -- Keep the project-root compile_commands.json symlink in sync with
    -- the active CMake preset. Without this clangd would always read
    -- whichever build dir was symlinked first (typically Debug), so
    -- branches gated by NDEBUG (e.g. zofirewall flush+drop on init)
    -- show as inactive in Release builds. We also LspRestart so the
    -- new database takes effect immediately.
    local function refresh_compile_commands_symlink()
      local ok, ct = pcall(require, "cmake-tools")
      if not ok or not ct.get_build_directory then
        return
      end
      -- get_build_directory() returns a plenary Path object, not a string.
      -- .filename is the absolute path; fall back to tostring() in case
      -- of API drift.
      local build_dir_obj = ct.get_build_directory()
      if not build_dir_obj then
        return
      end
      local build_dir = build_dir_obj.filename or tostring(build_dir_obj)
      if not build_dir or build_dir == "" then
        return
      end
      local target = build_dir .. "/compile_commands.json"
      if vim.fn.filereadable(target) ~= 1 then
        return
      end
      local cwd = vim.fn.getcwd()
      local link = cwd .. "/compile_commands.json"
      pcall(vim.fn.delete, link)
      vim.fn.system({ "ln", "-sf", target, link })
      local short = vim.fn.fnamemodify(build_dir, ":~:.")
      vim.notify("compile_commands.json -> " .. short, vim.log.levels.INFO)
      pcall(vim.cmd, "LspRestart clangd")
    end

    -- cmake-tools.nvim only emits a single User event (CMakeToolsEnterProject)
    -- so we can't hook preset changes via autocmds. Wrapping the module
    -- functions (cmake_tools.select_configure_preset = ...) doesn't work
    -- either because nvim_create_user_command captures the function
    -- reference at command creation time. So we re-register the user
    -- commands ourselves, calling the original and then our refresh.
    -- defer_fn gives cmake-tools a tick to write its session before we
    -- read get_build_directory().
    -- cmake-tools' select_*_preset only updates config.configure_preset /
    -- config.build_type. The actual build_directory is rewritten inside
    -- cmake.generate() (init.lua:161 → config:update_build_dir). If we
    -- skip generate, get_build_directory() still returns the previous
    -- preset's path and we'd symlink to the wrong CDB. So our wrapper
    -- replicates cmake-tools' default callback (run generate on success)
    -- and only then refreshes the symlink.
    local function override_select(cmd_name, fn_name)
      local ct = require("cmake-tools")
      local original = ct[fn_name]
      if not original then
        return
      end
      vim.api.nvim_create_user_command(cmd_name, function()
        original(function(result)
          if result and result.is_ok and result:is_ok() then
            ct.generate({ bang = false, fargs = {} }, function()
              vim.defer_fn(refresh_compile_commands_symlink, 50)
            end)
          end
        end)
      end, { nargs = 0, desc = cmd_name .. " (auto compile_commands symlink)" })
    end

    override_select("CMakeSelectConfigurePreset", "select_configure_preset")
    override_select("CMakeSelectBuildPreset", "select_build_preset")
    override_select("CMakeSelectBuildType", "select_build_type")
    override_select("CMakeSelectKit", "select_kit")

    -- Also expose as a user command for manual refresh.
    vim.api.nvim_create_user_command(
      "CMakeRefreshCompileCommands",
      refresh_compile_commands_symlink,
      { desc = "Re-point compile_commands.json symlink at the active preset's build dir" }
    )
  end,
}
