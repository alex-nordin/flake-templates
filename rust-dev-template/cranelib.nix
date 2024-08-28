{
  lib,
  config,
  pkgs,
  self,
  flake-parts-lib,
  ...
}: let
  inherit
    (flake-parts-lib)
    mkPerSystemOption
    ;
in {
  options = {
    perSystem =
      mkPerSystemOption
      ({
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        # webbed_site.overrideCraneArgs = lib.mkOption {
        #   type = lib.types.functionTo lib.types.attrs;
        #   default = _: {};
        #   description = "Override crane args for the webbed_site package";
        # };

        my-crate.rustToolchain = lib.mkOption {
          type = lib.types.package;
          description = "Rust toolchain to use for the webbed_site package";
          default = (pkgs.rust-bin.fromRustupToolchainFile (self' + /rust-toolchain.toml)).override {
            extensions = [
              "rust-src"
              "rust-analyzer"
              "clippy"
            ];
          };
        };

        my-crate.craneLib = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          default = (inputs'.crane.mkLib pkgs).overrideToolchain config.my-crate.rustToolchain;
        };
      });
  };

  config = let
    cargoToml = builtins.fromTOML (builtins.readFile (self + /Cargo.toml));
    inherit (cargoToml.package) name;
    inherit (config.my-crate) craneLib;

    my-crate = craneLib.buildPackage {
      src = craneLib.cleanCargoSource ./.;
      strictDeps = true;
    };
  in {
    packages.${name} = my-crate.package;
    packages."${name}-doc" = my-crate.doc;

    checks."${name}-clippy" = my-crate.check;
  };
  # my-crate = craneLib.
}
