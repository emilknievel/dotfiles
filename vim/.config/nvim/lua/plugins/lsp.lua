return {

  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- LSP Support
      "neovim/nvim-lspconfig",
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "rafamadriz/friendly-snippets" },

      {
        "glepnir/lspsaga.nvim",
        event = "LspAttach",
        config = function()
          require("lspsaga").setup({})
        end,
        keys = {
          { "<leader>ca", "<cmd>Lspsaga code_action<CR>", mode = "n" },
        },
      },

      "onsails/lspkind-nvim",              -- vscode-like pictograms
      "joechrisellis/lsp-format-modifications.nvim",
      "Hoffs/omnisharp-extended-lsp.nvim", -- extended textDocument/definition handler
    },

    config = function()
      local lsp = require('lsp-zero').preset('recommended')

      local function to_snake_case(str)
        return string.gsub(str, "%s*[- ]%s*", "_")
      end

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({ buffer = bufnr })
      end)

      local homedir = os.getenv("HOME")
      local pid = vim.fn.getpid()
      local sysname = vim.loop.os_uname().sysname
      local omnisharp_bin
      if sysname == "Darwin" then
        omnisharp_bin = homedir .. "/.local/share/nvim/mason/packages/omnisharp/OmniSharp"
      elseif sysname == "Linux" then
        omnisharp_bin = homedir .. "/.local/share/nvim/mason/bin/omnisharp"
      end -- TODO: Windows support

      local config = {
        handlers = {
          ["textDocument/definition"] = require('omnisharp_extended').handler,
        },
        cmd = { omnisharp_bin, '--languageserver', '--hostPID', tostring(pid) },
        -- Enables support for reading code style, naming convention and analyzer
        -- settings from .editorconfig.
        enable_editorconfig_support = true,

        -- If true, MSBuild project system will only load projects for files that
        -- were opened in the editor. This setting is useful for big C# codebases
        -- and allows for faster initialization of code navigation features only
        -- for projects that are relevant to code that is being edited. With this
        -- setting enabled OmniSharp may load fewer projects and may thus display
        -- incomplete reference lists for symbols.
        enable_ms_build_load_projects_on_demand = false,

        -- Enables support for roslyn analyzers, code fixes and rulesets.
        enable_roslyn_analyzers = true,

        -- Specifies whether 'using' directives should be grouped and sorted during
        -- document formatting.
        organize_imports_on_format = false,

        -- Enables support for showing unimported types and unimported extension
        -- methods in completion lists. When committed, the appropriate using
        -- directive will be added at the top of the current file. This option can
        -- have a negative impact on initial completion responsiveness,
        -- particularly for the first few completion sessions after opening a
        -- solution.
        enable_import_completion = false,

        -- Specifies whether to include preview versions of the .NET SDK when
        -- determining which version to use for project loading.
        sdk_include_prereleases = true,

        -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
        -- true
        analyze_open_documents_only = false,
      }

      require 'lspconfig'.omnisharp.setup(config)

      require 'lspconfig'.lua_ls.setup {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      }

      lsp.setup()

      -- You need to setup `cmp` after lsp-zero
      local cmp = require('cmp')
      local cmp_action = require('lsp-zero').cmp_action()

      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup({
        preselect = 'item',
        completion = {
          completeopt = 'menu,menuone,noinsert'
        },
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'buffer',  keyword_length = 3 },
          { name = 'luasnip', keyword_length = 2 },
        },
        formatting = {
          fields = { 'abbr', 'kind', 'menu' },
          format = require('lspkind').cmp_format({
            mode = 'symbol',       -- show only symbol annotations
            maxwidth = 50,         -- prevent the popup from showing more than provided characters
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
          })
        },
        mapping = {
          -- `Enter` key to confirm completion
          ['<CR>'] = cmp.mapping.confirm({ select = false }),

          -- Ctrl+Space to trigger completion menu
          ['<C-Space>'] = cmp.mapping.complete(),

          -- Navigate between snippet placeholder
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
          ['<Tab>'] = cmp_action.luasnip_supertab(),
          ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
        }
      })
    end,

  },

}
