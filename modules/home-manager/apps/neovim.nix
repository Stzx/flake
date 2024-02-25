{ config, lib, pkgs, ... }:

let
  cfg = config.want;

  lua_cfg = plugin: config: {
    inherit plugin config;

    type = "lua";
  };

  nvim-twp = pkgs.vimPlugins.nvim-treesitter.withPlugins (parser: with parser; [
    comment
    diff
    regex
    udev
    vimdoc
    latex

    nix
    bash
    nasm
    c
    rust
    kotlin
    lua
    python
    css

    qmljs
    qmldir

    make
    cmake

    csv
    ini
    xml
    toml
    yaml
    json
    markdown
  ]);
in
{
  options.want.nvim = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Install Neovim";
  };

  config = lib.mkIf cfg.nvim {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
      extraPackages = with pkgs; [
        wl-clipboard
      ];
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

        o.swapfile = false
        o.backup = false
        o.writebackup = false

        require("ibl").setup()
      '';
      plugins = with pkgs.vimPlugins; [
        nvim-web-devicons

        (lua_cfg monokai-pro-nvim ''
          require('monokai-pro').setup {
            transparent_background = true,
          }

          vim.cmd([[colorscheme monokai-pro-classic]])
        '')

        (lua_cfg nvim-tree-lua ''
          require('nvim-tree').setup {
            view = {
              width = 50,
            },
          }
        '')

        (lua_cfg bufferline-nvim ''
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

        (lua_cfg lualine-nvim ''
          require('lualine').setup {
            options = {
              disabled_filetypes = { 'NvimTree' },
            },
          }
        '')

        (lua_cfg gitsigns-nvim ''
          require('gitsigns').setup {
            numhl = true,
          }
        '')

        indent-blankline-nvim

        nvim-lspconfig

        (lua_cfg nvim-twp ''
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

        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline

        (lua_cfg cmp-snippy ''
          local cmp = require('cmp')

          cmp.setup({
            snippet = {
              expand = function(args)
                require('snippy').expand_snippet(args.body)
              end,
            },
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
              { name = 'snippy' },
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
                  command = { 'nixpkgs-fmt' },
                },
              },
            },
          }

          vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
        '')
      ];
    };
  };
}
