local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end

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

