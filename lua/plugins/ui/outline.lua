--[[
================================================================================
OUTLINE (CODE OUTLINE SIDEBAR)
================================================================================
Sidebar con árbol jerárquico de símbolos (clases, métodos, variables).
Usa LSP (clangd) como provider principal.
Keymaps:
  <leader>cs - Toggle sidebar
  Dentro del outline:
    <CR>     - Ir al símbolo
    o        - Peek sin salir
    K        - Preview
    h/l      - Fold/unfold
    W/E      - Fold/unfold all
    q/<Esc>  - Cerrar
Plugin: hedyhli/outline.nvim
================================================================================
--]]

return {
  "hedyhli/outline.nvim",
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline (symbols)" },
    { "<leader>cS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Project symbols (all classes)" },
  },
  config = function(_, opts)
    -- Colores estilo Visual Studio Class View
    vim.api.nvim_set_hl(0, "OutlineVSClass", { fg = "#E8AB53" })     -- naranja dorado
    vim.api.nvim_set_hl(0, "OutlineVSStruct", { fg = "#86C691" })    -- verde claro
    vim.api.nvim_set_hl(0, "OutlineVSMethod", { fg = "#DCDCAA" })    -- amarillo
    vim.api.nvim_set_hl(0, "OutlineVSFunction", { fg = "#DCDCAA" })  -- amarillo
    vim.api.nvim_set_hl(0, "OutlineVSConstructor", { fg = "#B586CF" }) -- morado
    vim.api.nvim_set_hl(0, "OutlineVSField", { fg = "#9CDCFE" })     -- azul claro
    vim.api.nvim_set_hl(0, "OutlineVSVariable", { fg = "#9CDCFE" })  -- azul claro
    vim.api.nvim_set_hl(0, "OutlineVSProperty", { fg = "#9CDCFE" })  -- azul claro
    vim.api.nvim_set_hl(0, "OutlineVSEnum", { fg = "#B8D7A3" })      -- verde
    vim.api.nvim_set_hl(0, "OutlineVSEnumMember", { fg = "#B8D7A3" }) -- verde
    vim.api.nvim_set_hl(0, "OutlineVSInterface", { fg = "#B8D7A3" }) -- verde
    vim.api.nvim_set_hl(0, "OutlineVSNamespace", { fg = "#D4D4D4" }) -- gris claro
    vim.api.nvim_set_hl(0, "OutlineVSModule", { fg = "#D4D4D4" })    -- gris claro

    require("outline").setup(opts)
  end,
  opts = {
    outline_window = {
      position = "right",
      width = 35,
      relative_width = false,
      auto_close = false,
      auto_jump = false,
      show_numbers = false,
      show_relative_numbers = false,
      wrap = false,
      show_cursorline = true,
      focus_on_open = false,
    },
    outline_items = {
      show_symbol_details = true,
      show_symbol_lineno = true,
      highlight_hovered_item = true,
      auto_set_cursor = true,
    },
    symbol_folding = {
      autofold_depth = false,
      markers = { "", "" },
    },
    guides = {
      enabled = true,
      markers = {
        bottom = "└",
        middle = "├",
        vertical = "│",
      },
    },
    preview_window = {
      auto_preview = false,
      border = "rounded",
    },
    symbols = {
      filter = {
        default = {
          "Class",
          "Constructor",
          "Enum",
          "EnumMember",
          "Field",
          "Function",
          "Interface",
          "Method",
          "Module",
          "Namespace",
          "Property",
          "Struct",
          "Variable",
        },
      },
      icons = {
        Class = { icon = " ", hl = "OutlineVSClass" },
        Constructor = { icon = " ", hl = "OutlineVSConstructor" },
        Enum = { icon = " ", hl = "OutlineVSEnum" },
        EnumMember = { icon = " ", hl = "OutlineVSEnumMember" },
        Field = { icon = " ", hl = "OutlineVSField" },
        Function = { icon = "󰊕 ", hl = "OutlineVSFunction" },
        Interface = { icon = " ", hl = "OutlineVSInterface" },
        Method = { icon = "󰊕 ", hl = "OutlineVSMethod" },
        Module = { icon = " ", hl = "OutlineVSModule" },
        Namespace = { icon = " ", hl = "OutlineVSNamespace" },
        Property = { icon = " ", hl = "OutlineVSProperty" },
        Struct = { icon = " ", hl = "OutlineVSStruct" },
        Variable = { icon = " ", hl = "OutlineVSVariable" },
      },
    },
    providers = {
      priority = { "lsp" },
    },
  },
}
