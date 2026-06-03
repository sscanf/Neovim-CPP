-- Custom overrides for Flutter / Dart language support.
-- Activated via lazyvim.json → "lazyvim.plugins.extras.lang.dart".
return {
    {
        "akinsho/flutter-tools.nvim",
        opts = {
            flutter_path = vim.fn.expand("~/flutter/bin/flutter"),
            fvm = false,
            widget_guides = { enabled = true },
            closing_tags = {
                highlight = "Comment",
                prefix = "// ",
                enabled = true,
            },
            dev_log = {
                enabled = true,
                open_cmd = "tabedit",
            },
            lsp = {
                color = { enabled = true, background = false, virtual_text = true },
                settings = {
                    showTodos = true,
                    completeFunctionCalls = true,
                    enableSnippets = true,
                    updateImportsOnRename = true,
                },
                on_attach = function(_, bufnr)
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function() vim.lsp.buf.format({ async = false }) end,
                    })
                    -- Flutter commands invoked from cmdline (`:FlutterRun`,
                    -- `:FlutterReload`, `:FlutterDeploy`, …). No keymap
                    -- prefix to avoid clashing with LazyVim defaults.
                end,
            },
        },
        config = function(_, opts)
            require("flutter-tools").setup(opts)

            -- :FlutterDeploy — builds debug bundle and rsyncs flutter_assets/
            -- to /opt/zone_flutter_poc/data/ on the triton cabinet, then
            -- prints the launch command. The cabinet IP is read from the
            -- TRITON_HOST env var (defaults to 192.168.1.165).
            -- nvim's :terminal launches a non-login shell that does not
            -- source ~/.zshrc, so `flutter` may not be on PATH. Use the
            -- absolute path resolved at config-load time (or fall back
            -- to PATH if the user keeps Flutter elsewhere).
            local flutter_bin = vim.fn.expand("~/flutter/bin/flutter")
            if vim.fn.executable(flutter_bin) ~= 1 then
                flutter_bin = "flutter"
            end

            -- :FlutterBuild [debug|profile|release] — builds the bundle in a
            -- split terminal. Defaults to debug. Output goes to
            -- build/flutter_assets/.
            vim.api.nvim_create_user_command("FlutterBuild", function(args)
                local mode = args.args ~= "" and args.args or "debug"
                vim.notify("flutter build bundle --" .. mode, vim.log.levels.INFO)
                vim.cmd("split | resize 12 | terminal " .. flutter_bin .. " build bundle --" .. mode)
            end, {
                nargs = "?",
                desc = "Build Flutter bundle (debug|profile|release)",
                complete = function() return { "debug", "profile", "release" } end,
            })

            -- :FlutterDeploy — builds debug bundle and rsyncs flutter_assets/
            -- to /opt/zone_flutter_poc/data/ on the triton cabinet. Cabinet
            -- IP read from TRITON_HOST env var (default 192.168.1.165).
            vim.api.nvim_create_user_command("FlutterDeploy", function()
                local target = vim.env.TRITON_HOST or "192.168.1.165"
                local cmd = string.format(
                    "%s build bundle --debug && sshpass -p root rsync -e 'ssh -p2222 -o StrictHostKeyChecking=no' -a --delete build/flutter_assets/ root@%s:/opt/zone_flutter_poc/data/flutter_assets/",
                    flutter_bin, target
                )
                vim.notify("Deploying to " .. target, vim.log.levels.INFO)
                vim.cmd("split | resize 12 | terminal " .. cmd)
            end, { desc = "Build debug bundle and rsync to cabinet" })
        end,
    },
}
