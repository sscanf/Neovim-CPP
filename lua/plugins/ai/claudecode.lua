--[[
================================================================================
CLAUDE CODE INTEGRATION
================================================================================
Integrates Claude Code CLI as an AI assistant within Neovim.
Features:
  - Toggle Claude terminal with <leader>ac
  - Focus Claude window with <leader>af
  - Send visual selections to Claude with <leader>as
  - Add files to context with <leader>aa
Plugin: coder/claudecode.nvim
================================================================================
--]]

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    opts = {
      terminal_cmd = vim.fn.expand("~/.local/bin/claude"),
      terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "snacks",
      },
      auto_start = true,
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file to Claude context" },
    },
  },
}
