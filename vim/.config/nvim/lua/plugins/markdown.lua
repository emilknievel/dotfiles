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
    end,
  },
}
