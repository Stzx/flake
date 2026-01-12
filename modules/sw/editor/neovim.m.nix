{
  home =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      cfg = config.programs.neovim;

      lpc = plugin: config: {
        inherit plugin config;

        type = "lua";
      };

      nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
        parser: with parser; [
          awk
          comment
          csv
          desktop
          diff
          disassembly
          dot
          editorconfig
          git_config
          git_rebase
          gitattributes
          gitcommit
          ini
          jq
          json
          json5
          kdl
          kconfig
          luadoc
          markdown
          mermaid
          objdump
          properties
          proto
          toml
          udev
          vimdoc
          xml
          yaml

          asm
          c
          cpp
          css
          # dart
          # elixir
          # erlang
          # go
          # groovy
          html
          # java
          # javascript
          # kotlin
          # latex
          lua
          nasm
          nix
          # perl
          # python
          # rust
          vim

          bash
          cmake
          dockerfile
          make
          meson
          regex
          sql
          wit
        ]
      );
    in
    {
      config = lib.mkIf cfg.enable {
        programs.neovim = {
          defaultEditor = true;
          vimAlias = true;
          vimdiffAlias = true;
          withNodeJs = false;
          withPython3 = false;
          withRuby = false;
          extraPackages = with pkgs; [ nil ];
          extraLuaPackages = _: [ ];
          extraLuaConfig = ''
            local opt = vim.opt

            opt.number = true
            opt.relativenumber = true
            opt.cursorline = true
            opt.termguicolors = true
            opt.laststatus = 3

            opt.expandtab = true
            opt.tabstop = 4
            opt.shiftwidth = 4
          '';
          plugins = with pkgs.vimPlugins; [
            (lpc nvim-web-devicons ''
              require('nvim-web-devicons').setup()
            '')

            (lpc monokai-pro-nvim ''
              require('monokai-pro').setup({
                  transparent_background = true,
                  filter = 'classic',
              })

              vim.cmd([[colorscheme monokai-pro]])
            '')

            (lpc nvim-tree-lua ''
              require('nvim-tree').setup({
                view = {
                  width = 75,
                },
                renderer = {
                  indent_markers = {
                    enable = true,
                  },
                },
              })
            '')

            (lpc bufferline-nvim ''
              require('bufferline').setup({
                options = {
                  separator_style = 'slope',
                  offsets = {
                    {
                      filetype = "NvimTree",
                      text = "File Explorer",
                      text_align = "center",
                      separator = true,
                    },
                  },
                },
              })
            '')

            (lpc lualine-nvim ''
              require('lualine').setup({
                options = {
                  theme = 'monokai-pro',
                  disabled_filetypes = {
                    'NvimTree',
                  },
                  -- extensions = { 'nvim-tree', },
                },
              })
            '')

            (lpc indent-blankline-nvim ''
              require("ibl").setup()
            '')

            (lpc nvim-treesitter ''
              require('nvim-treesitter').setup({
                auto_install = false,
                highlight = {
                  enable = true,
                },
                indent = {
                  enable = true,
                },
              })
            '')

            (lpc nvim-lspconfig ''
              vim.lsp.enable('nil_ls')
            '')
          ];
        };
      };
    };
}
