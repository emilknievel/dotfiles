local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end
local status3, mason_null_ls = pcall(require, "mason-null-ls")
if (not status3) then return end
local status4, null_ls = pcall(require, "null-ls")
if (not status4) then return end

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

mason.setup({

})

lspconfig.setup {
  ensure_installed = {
    "awk_ls",
    "bashls",
    "cssls",
    "dockerls",
    "gopls",
    "graphql",
    "jsonls",
    "marksman",
    "omnisharp",
    "pylsp",
    "rust_analyzer",
    "sumneko_lua",
    "tailwindcss",
    "tsserver",
    "volar",
    "yamlls",
  },
}

mason_null_ls.setup({
  ensure_installed = {
    "prettierd",
    "eslint_d",
    "gofumpt",
    "jq",
  },
  automatic_installation = false,
  automatic_setup = true, -- Recommended, but optional
})

null_ls.setup({
  sources = {
      -- Anything not supported by mason.
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<Leader>fm", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })

      -- format on save
      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, async = async })
        end,
        desc = "[lsp] format on save",
      })
    end

    if client.supports_method("textDocument/rangeFormatting") then
      vim.keymap.set("x", "<Leader>fm", function()
        vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
      end, { buffer = bufnr, desc = "[lsp] format" })
    end
  end,
})

mason_null_ls.setup_handlers()


