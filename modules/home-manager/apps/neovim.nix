{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.programs.neovim;

  luaCfg = plugin: config: {
    inherit plugin config;

    type = "lua";
  };

  nvim-twp = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    parser: with parser; [
      awk
      bash
      comment
      diff
      kconfig
      regex
      udev
      vim
      vimdoc

      asm
      c
      css
      dart
      html
      lua
      nasm
      nix

      cmake
      csv
      dockerfile
      ini
      json
      make
      markdown
      ninja
      properties
      proto
      toml
      xml
      yaml
    ]
  );
in
lib.mkIf cfg.enable {
  programs.neovim = {
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
    extraLuaConfig = ''
      local o = vim.opt

      o.cursorline = true
      o.expandtab = true
      o.number = true
      o.list = true
      o.shiftwidth = 4
      o.tabstop = 4
      o.relativenumber = true
      o.termguicolors = true
      o.colorcolumn = '80'

      o.swapfile = false
      o.backup = false
      o.writebackup = false

      require("ibl").setup()
    '';
    plugins = with pkgs.vimPlugins; [
      nvim-web-devicons

      (luaCfg monokai-pro-nvim ''
        require('monokai-pro').setup {
          transparent_background = true,
        }

        vim.cmd([[colorscheme monokai-pro-classic]])
      '')

      (luaCfg nvim-tree-lua ''
        require('nvim-tree').setup {
          view = {
            width = 50,
          },
        }
      '')

      (luaCfg bufferline-nvim ''
        require('bufferline').setup {
          options = {
            separator_style = 'slope',
            offsets = {
             {
                filetype = 'NvimTree',
                text = 'File Explorer',
                text_align = 'center',
                separator = true
              },
            },
          },
        }
      '')

      (luaCfg lualine-nvim ''
        require('lualine').setup {
          options = {
            disabled_filetypes = { 'NvimTree' },
          },
        }
      '')

      (luaCfg gitsigns-nvim ''
        require('gitsigns').setup {
          numhl = true,
        }
      '')

      indent-blankline-nvim

      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline

      nvim-lspconfig

      (luaCfg nvim-twp ''
        require('nvim-treesitter.configs').setup {
          auto_install = false,
          highlight = {
            enable = true,
          },
          indent = {
            enable = true,
          },
        }
      '')

      (luaCfg nvim-cmp ''
        local cmp = require('cmp')

        cmp.setup({
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
          }, {
            { name = 'buffer' },
          })
        })

        -- Set configuration for specific filetype.
        cmp.setup.filetype('gitcommit', {
          sources = cmp.config.sources({
            { name = 'git' },
          }, {
            { name = 'buffer' },
          })
        })

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ '/', '?' }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = 'buffer' }
          }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })

        local caps = require('cmp_nvim_lsp').default_capabilities()

        require('lspconfig').nil_ls.setup {
          capabilities = caps,
          settings = {
            ['nil'] = {
              formatting = {
                command = { 'nixfmt' },
              },
            },
          },
        }

        vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
      '')
    ];
  };
}
