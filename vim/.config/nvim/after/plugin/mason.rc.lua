local status, mason = pcall(require, "mason")
if not status then
  return
end
local status2, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status2 then
  return
end
local status3, mason_null_ls = pcall(require, "mason-null-ls")
if not status3 then
  return
end
local status4, null_ls = pcall(require, "null-ls")
if not status4 then
  return
end

-- local group = vim.api.nvim_create_augroup('lsp_format_on_save', { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

mason.setup {}

mason_lspconfig.setup {
  ensure_installed = {
    "awk_ls",
    "bashls",
    "clojure_lsp",
    "cssls",
    "dockerls",
    "gopls",
    "graphql",
    "jsonls",
    "marksman",
    "omnisharp",
    "pylsp",
    "rust_analyzer",
    "lua_ls",
    "solargraph",
    "tailwindcss",
    "tsserver",
    "volar",
    "yamlls",
  },
}

mason_null_ls.setup {
  ensure_installed = {
    "prettierd",
    "eslint_d",
    "gofumpt",
    "jq",
    "stylua",
  },
  automatic_installation = false,
  automatic_setup = true, -- Recommended, but optional
}

null_ls.setup {
  sources = {
    -- Anything not supported by mason.
    null_ls.builtins.formatting.stylua.with {
      extra_args = {
        "--config-path",
        vim.fn.expand "~/.config/nvim/stylua.toml",
      },
    },

    -- eslint_d as default linter
    null_ls.builtins.diagnostics.eslint_d.with({
      only_local = 'node_modules/.bin'
    }),
    -- eslint_d as default for code actions
    null_ls.builtins.code_actions.eslint_d.with({
      only_local = 'node_modules/.bin'
    }),

    null_ls.builtins.formatting.prettier,
  },
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.keymap.set("n", "<Leader>fm", function()
        vim.lsp.buf.format {
          bufnr = vim.api.nvim_get_current_buf(),
        }
      end, { buffer = bufnr, desc = "[lsp] format" })

      -- format on save
      -- vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      -- vim.api.nvim_create_autocmd(event, {
      --     buffer = bufnr,
      --     group = group,
      --     callback = function()
      --         vim.lsp.buf.format({ bufnr = bufnr, async = async })
      --     end,
      --     desc = '[lsp] format on save',
      -- })
    end
    if client.supports_method "textDocument/rangeFormatting" then
      local lsp_format_modifications = require"lsp-format-modifications"
      lsp_format_modifications.attach(client, bufnr, { format_on_save = true })

      vim.keymap.set("x", "<Leader>fm", function()
        vim.lsp.buf.format {
          bufnr = vim.api.nvim_get_current_buf(),
        }
      end, { buffer = bufnr, desc = "[lsp] format" })
    end

    -- local lsp_format_modifications = require('lsp-format-modifications')
    -- lsp_format_modifications.attach(client, bufnr, { format_on_save = true })
  end,
}

mason_null_ls.setup_handlers()
-- mason_null_ls.setup_handlers({
-- 	function(source_name, methods)
-- 		-- all sources with no handler get passed here
-- 	end,
-- 	stylua = function(source_name, methods)
-- 		null_ls.builtins.formatting.stylua.with({
-- 			extra_args = { "--config-path", vim.fn.expand("~/.config/stylua.toml") },
-- 		})
-- 	end,
-- })
