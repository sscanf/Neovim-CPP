--[[
================================================================================
LOCAL LLM INTEGRATION (llama.cpp)
================================================================================
Integrates the local llama-server (Qwen3.6-35B-A3B) via CodeCompanion.
Server is started with ~/projects/ollama/start.sh (OpenAI-compatible API).
Features:
  - Toggle chat buffer with <leader>oc (new chats include the current buffer)
  - Actions palette with <leader>oa
  - Inline edit/generate with <leader>oi (works on visual selection)
  - Add visual selection to chat with <leader>os
  - Toggle opencode agent in a right split with <leader>oo
  - Chat has the @{files} tool group enabled by default (read/create/edit files)
Plugin: olimorris/codecompanion.nvim
================================================================================
--]]

local LLAMA_URL = "http://127.0.0.1:8080"
-- API key read from the environment (export LLAMA_API_KEY=... in your shell rc)
local LLAMA_API_KEY = os.getenv("LLAMA_API_KEY") or ""
local LLAMA_MODEL = "qwen3.6-35b-a3b"

-- Toggle the chat; a new chat starts with the current buffer attached
-- (#{buffer}{all}) so the LLM edits that file instead of creating a new one.
local function toggle_chat_with_buffer()
  local cc = require("codecompanion")
  local chat = cc.last_chat()
  if chat then
    return cc.toggle_chat()
  end
  chat = cc.chat()
  if not chat then
    return
  end
  local last = vim.api.nvim_buf_line_count(chat.bufnr)
  vim.api.nvim_buf_set_lines(chat.bufnr, last - 1, last, false, { "#{buffer}{all} " })
  vim.api.nvim_win_set_cursor(0, { last, #"#{buffer}{all} " })
end

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    opts = {
      adapters = {
        http = {
          llamacpp = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "llamacpp",
              formatted_name = "llama.cpp (Qwen3.6)",
              env = {
                url = LLAMA_URL,
                api_key = LLAMA_API_KEY,
                chat_url = "/v1/chat/completions",
                models_endpoint = "/v1/models",
              },
              schema = {
                model = { default = LLAMA_MODEL },
              },
            })
          end,
        },
      },
      interactions = {
        background = { adapter = "llamacpp" },
        chat = {
          adapter = "llamacpp",
          tools = {
            opts = {
              -- File tools always available in chat
              default_tools = { "files" },
            },
            -- Read and edit files directly, without approval prompts (undo with `u`).
            -- delete_file keeps asking for approval.
            read_file = { opts = { require_approval_before = false } },
            grep_search = { opts = { require_approval_before = false } },
            create_file = { opts = { require_confirmation_after = false } },
            insert_edit_into_file = { opts = { require_confirmation_after = false } },
          },
        },
        inline = { adapter = "llamacpp" },
        cmd = { adapter = "llamacpp" },
      },
      opts = {
        language = "Spanish",
      },
    },
    keys = {
      { "<leader>o", "", desc = "+local AI (llama.cpp)", mode = { "n", "v" } },
      { "<leader>oc", toggle_chat_with_buffer, desc = "Toggle chat (with current buffer)" },
      { "<leader>oa", "<cmd>CodeCompanionActions<cr>", desc = "Actions", mode = { "n", "v" } },
      { "<leader>oi", ":CodeCompanion ", desc = "Inline prompt", mode = { "n", "v" } },
      { "<leader>os", "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to chat", mode = "v" },
    },
  },
  {
    -- opencode agent (uses ~/.config/opencode/opencode.json -> local llama.cpp)
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>oo",
        function()
          Snacks.terminal.toggle("opencode", {
            cwd = LazyVim.root(),
            win = { position = "right", width = 0.4 },
          })
        end,
        desc = "Toggle opencode (local agent)",
      },
    },
  },
}
