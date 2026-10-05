--[[
================================================================================
PDF VIEWER - GRAPHICAL PDF RENDERING IN NEOVIM
================================================================================
Converts PDF pages to PNG with pdftoppm and renders them inline using
image.nvim (Kitty graphics protocol). Works over SSH with `kitten ssh`.
Dependencies:
  - poppler (brew install poppler) for pdftoppm
  - image.nvim (already configured)
================================================================================
--]]

vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "*.pdf",
  callback = function(args)
    local path = vim.fn.fnamemodify(vim.fn.expand(args.match), ":p")
    local buf = args.buf

    -- Create temp dir for page images
    local tmpdir = vim.fn.tempname() .. "_pdf"
    vim.fn.mkdir(tmpdir, "p")

    -- Get page count
    local page_info = vim.fn.system({ "pdfinfo", path })
    local pages = tonumber(page_info:match("Pages:%s+(%d+)")) or 1

    -- Convert all pages to PNG
    vim.fn.system({
      "pdftoppm", "-png", "-r", "350", path, tmpdir .. "/page",
    })

    if vim.v.shell_error ~= 0 then
      vim.bo[buf].buftype = "nofile"
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "Error: pdftoppm failed. Install with: brew install poppler",
      })
      return
    end

    -- Build markdown buffer with image references for image.nvim
    local lines = {}
    table.insert(lines, "# " .. vim.fn.fnamemodify(path, ":t") .. " (" .. pages .. " pages)")
    table.insert(lines, "")

    for i = 1, pages do
      local img = string.format("%s/page-%02d.png", tmpdir, i)
      -- pdftoppm may use different padding depending on page count
      if vim.fn.filereadable(img) == 0 then
        img = string.format("%s/page-%d.png", tmpdir, i)
      end
      if vim.fn.filereadable(img) == 0 then
        img = string.format("%s/page-%03d.png", tmpdir, i)
      end
      if vim.fn.filereadable(img) == 1 then
        table.insert(lines, string.format("## Page %d", i))
        table.insert(lines, "")
        table.insert(lines, string.format("![page %d](%s)", i, img))
        table.insert(lines, "")
      end
    end

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "markdown"

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    -- Cleanup temp files when buffer is closed
    vim.api.nvim_create_autocmd("BufDelete", {
      buffer = buf,
      callback = function()
        vim.fn.delete(tmpdir, "rf")
      end,
    })
  end,
})

return {}
