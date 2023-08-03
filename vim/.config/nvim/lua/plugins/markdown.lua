local filetypes = { "md", "mkd", "mdwn", "mdown", "mdtxt", "mdtext", "markdown", "text" }

return {
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>md",
        vim.cmd.MarkdownPreviewToggle,
        desc = "Toggle markdown preview"
      },
    },
    ft = filetypes,
    config = function()
      vim.g.mkdp_filetypes = filetypes
      vim.g.mkdp_auto_close = true
      vim.g.mkdp_echo_preview_url = true
      vim.g.mkdp_page_title = "${name}"
    end,
  },
}
