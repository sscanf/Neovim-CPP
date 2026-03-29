--[[
================================================================================
IMAGE.NVIM - INLINE IMAGE DISPLAY
================================================================================
Renders images directly inside Neovim using the Kitty graphics protocol or
sixel. Supports previewing images in buffers and markdown files.
Dependencies:
  - ImageMagick (system package)
  - magick (luarocks package: luarocks --local --lua-version=5.1 install magick)
  - Terminal with Kitty graphics protocol or sixel support
Plugin: 3rd/image.nvim
================================================================================
--]]

return {
  "3rd/image.nvim",
  build = false,
  lazy = false,
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        only_render_image_at_cursor = false,
        floating_windows = false,
      },
    },
    max_width = nil,
    max_height = nil,
    max_height_window_percentage = nil,
    max_width_window_percentage = nil,
    window_overlap_clear_enabled = false,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  },
}
