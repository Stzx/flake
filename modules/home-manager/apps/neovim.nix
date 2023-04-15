{ config, lib, pkgs, ... }:

let
  cfg = config.want;

  treesitter-with-plugins = pkgs.vimPlugins.nvim-treesitter.withPlugins (parser: with parser; [
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
        vim.opt.cursorline = true
        vim.opt.expandtab = true
        vim.opt.number = true
        vim.opt.list = true
        vim.opt.shiftwidth = 4
        vim.opt.tabstop = 4
        vim.opt.relativenumber = true

        vim.opt.swapfile = false
        vim.opt.backup = false
        vim.opt.writebackup = false

        require('gitsigns').setup()

        require('crates').setup()
      '';
      plugins = with pkgs.vimPlugins; [
        gitsigns-nvim

        {
          type = "lua";
          plugin = monokai-pro-nvim;
          config = ''
            require('monokai-pro').setup {
              transparent_background = true
            }

            vim.cmd([[colorscheme monokai-pro-classic]])
          '';
        }

        {
          type = "lua";
          plugin = lualine-nvim;
          config = ''
            require('lualine').setup {
              options = {
                theme = 'monokai-pro-classic'
              }
            }
          '';
        }

        {
          type = "lua";
          plugin = hlchunk-nvim;
          config = ''
            require('hlchunk').setup {
                indent = {
                    enable = true,
                    use_treesitter = true,
                    chars = {
                        "│",
                    },
                    style = {
                        { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") }
                    },
                },
            }
          '';
        }

        nvim-web-devicons
        {
          type = "lua";
          plugin = neo-tree-nvim;
          config = ''
            require('neo-tree').setup {
              window = {
                width = 50,
              },
              filesystem = {
                filtered_items = {
                  hide_dotfiles = false,
                },
              },
            }
          '';
        }

        nvim-lspconfig

        {
          type = "lua";
          plugin = treesitter-with-plugins;
          config = ''
            require('nvim-treesitter.configs').setup {
              auto_install = false,
              highlight = {
                enable = true,
              },
              indent = {
                enable = true,
              }
            }
          '';
        }

        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        {
          type = "lua";
          plugin = cmp-snippy;
          config = ''
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
                    command = { "nixpkgs-fmt" },
                  }
                }
              }
            }

            vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
          '';
        }

        nvim-dap
        rustaceanvim
        crates-nvim
      ];
    };
  };
}
