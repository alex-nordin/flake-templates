{
  description = "Development shell for esp32 board";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # agenix-shell.url = "github:aciceri/agenix-shell";
    devenv.url = "github:cachix/devenv";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        # inputs.agenix-shell.flakeModules.default
        inputs.devenv.flakeModule
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
      ];
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        lib,
        ...
      }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.rust-overlay.overlays.default
          ];
        };

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        # packages.default = pkgs.hello;
        devenv.shells.default = {
          packages = with pkgs; [
            (rust-bin.selectLatestNightlyWith (toolchain:
              toolchain.default.override {
                extensions = ["rust-src"];
                targets = ["riscv32imc-unknown-none-elf"];
              }))
          ];
          buildInputs = with pkgs; [
            bashInteractive # fixes console in vscode

            cargo-generate # generate rust projects from github templates
            cargo-udeps # find unused dependencies in Cargo.toml
            openssl
            pkg-config

            # required for esp development
            espup # tool for installing esp-rs toolchain
            rustup # rust installer, required by espup
            espflash # flash binary to esp
            python3
          ];

          enterShell = ''
            echo -e "\e[1mInstalling toolchains for esp"
            echo -e "-----------------------------\e[0m"
            espup install
            . ~/export-esp.sh

            echo
            echo -e "\e[1mInstalling ldproxy"
            echo -e "------------------\e[0m"
            cargo install ldproxy
          '';

          # https://github.com/Mic92/nix-ld
          NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc
            pkgs.libxml2
          ];

          NIX_LD = pkgs.runCommand "ld.so" {} ''
            ln -s "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')" $out
          '';
        };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
