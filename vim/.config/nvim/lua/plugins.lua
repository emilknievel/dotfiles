local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')
    .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git',
      'clone',
      '--depth',
      '1',
      'https://github.com/wbthomason/packer.nvim',
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local status, packer = pcall(require, 'packer')
if not status then
  print('Packer is not installed')
  return
end

vim.cmd([[packadd packer.nvim]])

packer.startup(function(use)
  -- My plugins here
  use('wbthomason/packer.nvim')

  -- Themes
  use({
    'sainnhe/gruvbox-material',
  })
  use({
    'rose-pine/neovim',
    as = 'rose-pine',
  })
  use({ 'catppuccin/nvim', as = 'catppuccin' })

  -- Automatic toggling between line number modes
  use('jeffkreeftmeijer/vim-numbertoggle')
  use({
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  })
  use('onsails/lspkind-nvim') -- vscode-like pictograms
  use('hrsh7th/cmp-buffer') -- nvim-cmp source for buffer words
  use('hrsh7th/cmp-nvim-lsp') -- nvim-cmp source for neovim's built-in LSP
  use('hrsh7th/nvim-cmp') -- Completion
  use('williamboman/mason.nvim')
  use('williamboman/mason-lspconfig.nvim')
  use('glepnir/lspsaga.nvim') -- LSP UIs
  use('L3MON4D3/LuaSnip')
  -- use({
  --     'VonHeikemen/lsp-zero.nvim',
  --     requires = {
  --         -- LSP Support
  --         { 'neovim/nvim-lspconfig' },
  --         { 'williamboman/mason.nvim' },
  --         { 'williamboman/mason-lspconfig.nvim' },
  --
  --         -- Autocompletion
  --         { 'hrsh7th/nvim-cmp' },
  --         { 'hrsh7th/cmp-buffer' },
  --         { 'hrsh7th/cmp-path' },
  --         { 'saadparwaiz1/cmp_luasnip' },
  --         { 'hrsh7th/cmp-nvim-lsp' },
  --         { 'hrsh7th/cmp-nvim-lua' },
  --
  --         -- Snippets
  --         { 'L3MON4D3/LuaSnip' },
  --         { 'rafamadriz/friendly-snippets' },
  --     },
  -- })
  use({
    'nvim-treesitter/nvim-treesitter',
    run = function()
      require('nvim-treesitter.install').update({ with_sync = true })
    end,
  })
  use('nvim-treesitter/playground')
  use('neovim/nvim-lspconfig') -- Configurations for NVim LSP
  use('kyazdani42/nvim-web-devicons')
  use({
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } },
  })
  use('nvim-telescope/telescope-file-browser.nvim')
  use('windwp/nvim-autopairs')
  use('windwp/nvim-ts-autotag')
  use({
    'numToStr/Comment.nvim',
    config = function() require('Comment').setup() end,
  })
  use('jose-elias-alvarez/null-ls.nvim')
  use('jayp0521/mason-null-ls.nvim')
  use({
    'declancm/maximize.nvim', -- maximize window: <leader>z
    config = function() require('maximize').setup() end,
  })
  use({
    'kylechui/nvim-surround',
    tag = '*', -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require('nvim-surround').setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  })
  use({
    'lewis6991/gitsigns.nvim',
    -- tag = 'release' -- To use the latest release (do not use this if you run Neovim nightly or dev builds!)
  })
  use('eandrju/cellular-automaton.nvim')
  use('ThePrimeagen/vim-be-good')
  use({
    'folke/which-key.nvim',
    config = function() require('which-key').setup() end,
  })
  use('theprimeagen/harpoon')
  use('mbbill/undotree')
  use('tpope/vim-fugitive')
  use({
    'iamcco/markdown-preview.nvim',
    run = function() vim.fn['mkdp#util#install']() end,
  })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then require('packer').sync() end
end)
