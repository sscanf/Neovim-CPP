--[[
================================================================================
LOCAL AI AUTOCOMPLETION (llama.vim)
================================================================================
Copilot-style ghost-text suggestions from a local llama.cpp FIM server.
Server is started with ~/projects/ollama/start-fim.sh (Qwen2.5-Coder-1.5B, :8012).
Features:
  - Suggestions appear automatically while typing in insert mode
  - Accept full suggestion with <S-Tab> (Tab is reserved, see init.lua)
  - Accept first line with <C-l>, first word with <C-b>
  - Toggle auto suggestions with <leader>ot
Plugin: ggml-org/llama.vim
================================================================================
--]]

return {
  {
    "ggml-org/llama.vim",
    event = "InsertEnter",
    init = function()
      vim.g.llama_config = {
        endpoint_fim = "http://127.0.0.1:8012/infill",
        show_info = 0,
        keymap_fim_accept_full = "<S-Tab>",
        keymap_fim_accept_line = "<C-l>",
        keymap_fim_accept_word = "<C-b>",
        -- Defaults use <leader>ll... (clashes with <leader>l = Lazy, and in insert
        -- mode would delay every space). Instructions are covered by CodeCompanion.
        keymap_fim_trigger = "",
        keymap_fim_next = "",
        keymap_fim_prev = "",
        keymap_debug_toggle = "",
        keymap_inst_trigger = "",
        keymap_inst_rerun = "",
        keymap_inst_continue = "",
      }

      -- Gray suggestions (plugin default is orange); re-apply on colorscheme change
      local function set_hl()
        vim.api.nvim_set_hl(0, "llama_hl_fim_hint", { link = "Comment" })
      end
      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
    end,
    keys = {
      { "<leader>ot", "<cmd>LlamaToggle<cr>", desc = "Toggle AI autocompletion" },
    },
  },
}
