{
  description = "Julian's neovim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (inputs.nixCats) utils;
      luaPath = "${./.}";
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      extra_pkg_config = { };

      dependencyOverlays = [
        (utils.standardPluginOverlay inputs)
      ];

      categoryDefinitions =
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {

          lspsAndRuntimeDeps = {
            general   = with pkgs; [ universal-ctags ripgrep fd wl-clipboard xclip ];
            nix       = with pkgs; [ nixd ];
            neonixdev = with pkgs; { inherit nix-doc lua-language-server nixd; };
            webDev    = with pkgs; [
              typescript-language-server
              emmet-language-server
              eslint
              prettierd
              tailwindcss-language-server
              pkgs.vimPlugins.tailwindcss-colors-nvim
            ];
            lint   = with pkgs; [ shellcheck statix deadnix yamllint markdownlint-cli2 ];
            format = with pkgs; [ alejandra stylua shfmt taplo ];
          };

          startupPlugins = {
            general = with pkgs.vimPlugins; {
              always = [ lze lzextras vim-repeat plenary-nvim nvim-notify ];
              extra  = [ oil-nvim nvim-web-devicons ];
              custom = [ nvim-autopairs ];
            };
            webDev = with pkgs.vimPlugins; [ nvim-ts-autotag ];
            debug  = with pkgs.vimPlugins; [ nvim-nio ];
            themer = with pkgs.vimPlugins;
              (builtins.getAttr (categories.colorscheme or "catppuccin-frappe") {
                "onedark"           = onedark-nvim;
                "catppuccin"        = catppuccin-nvim;
                "catppuccin-mocha"  = catppuccin-nvim;
                "catppuccin-frappe" = catppuccin-nvim;
                "tokyonight"        = tokyonight-nvim;
                "tokyonight-day"    = tokyonight-nvim;
              });
          };

          optionalPlugins = {
            general = with pkgs.vimPlugins; {
              always = [
                nvim-lspconfig lualine-nvim gitsigns-nvim
                vim-sleuth vim-fugitive vim-rhubarb nvim-surround
              ];
              extra = [
                fidget-nvim which-key-nvim comment-nvim
                undotree indent-blankline-nvim vim-startuptime
              ];
              cmp = [
                nvim-cmp luasnip friendly-snippets cmp_luasnip
                cmp-buffer cmp-path cmp-nvim-lua cmp-nvim-lsp
                cmp-cmdline cmp-nvim-lsp-signature-help
                cmp-cmdline-history lspkind-nvim
              ];
              treesitter = [
                nvim-treesitter-textobjects
                nvim-treesitter.withAllGrammars
              ];
              telescope = [
                telescope-fzf-native-nvim
                telescope-ui-select-nvim
                telescope-nvim
              ];
            };
            debug.default = with pkgs.vimPlugins; [ nvim-dap nvim-dap-ui nvim-dap-virtual-text ];
            lint          = with pkgs.vimPlugins; [ nvim-lint ];
            format        = with pkgs.vimPlugins; [ conform-nvim ];
            markdown      = with pkgs.vimPlugins; [ markdown-preview-nvim ];
            neonixdev     = with pkgs.vimPlugins; [ lazydev-nvim ];
          };

          sharedLibraries    = { };
          environmentVariables = { };
          extraWrapperArgs   = { };
          extraLuaPackages.general = [ (_: [ ]) ];
          extraCats.debug = [ [ "debug" "default" ] ];
        };

      # ── presets ──────────────────────────────────────────────────────────
      #
      # basic  — core editor + nixd + markdown preview
      # config — basic + lua/nix dev tools (lua_ls, lazydev, lint, format)
      # coding — config + web dev, debug
      # full   — everything

      mkSettings = aliases: {
        wrapRc        = true;
        configDirName = "nixCats-nvim";
        inherit aliases;
      };

      packageDefinitions = {

        basic = { pkgs, ... }: {
          settings   = mkSettings [ "vi" ];
          categories = {
            general     = true;
            nix         = true;
            markdown    = true;
            themer      = true;
            colorscheme = "catppuccin-frappe";
          };
          extra = { };
        };

        config = { pkgs, ... }: {
          settings   = mkSettings [ "vim" ];
          categories = {
            general     = true;
            neonixdev   = true;
            lint        = true;
            format      = true;
            markdown    = true;
            themer      = true;
            colorscheme = "catppuccin-frappe";
          };
          extra.nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
        };

        coding = { pkgs, ... }: {
          settings   = mkSettings [ ];
          categories = {
            general     = true;
            neonixdev   = true;
            webDev      = true;
            lint        = true;
            format      = true;
            debug       = true;
            markdown    = true;
            themer      = true;
            colorscheme = "catppuccin-frappe";
          };
          extra.nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
        };

        full = { pkgs, ... }: {
          settings   = mkSettings [ "nvim" ];
          categories = {
            general      = true;
            neonixdev    = true;
            webDev       = true;
            lint         = true;
            format       = true;
            debug        = true;
            markdown     = true;
            themer       = true;
            colorscheme  = "catppuccin-frappe";
            lspDebugMode = false;
          };
          extra.nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
        };

      };

      defaultPackageName = "full";

    in
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages  = utils.mkAllWithDefault defaultPackage;
        devShells.default = pkgs.mkShell {
          name     = defaultPackageName;
          packages = [ defaultPackage ];
        };
      }
    )
    // (
      let
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;

        nixosModules.default = nixosModule;
        homeModules.default  = homeModule;

        inherit utils nixosModule homeModule;
        inherit (utils) templates;
      }
    );
}
