{
  self,
  lib,
  inputs,
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
        options = {
          my-crate.overrideCraneArgs = lib.mkOption {
            type = lib.types.functionTo lib.types.attrs;
            default = _: {};
            description = "Override crane args for crate";
          };

          my-crate.rustToolchain = lib.mkOption {
            type = lib.types.package;
            description = "Rust toolchain to use for my crate";
            default = (pkgs.rust-bin.fromRustupToolchainFile (self + /rust-toolchain.toml)).override {
              extensions = [
                "rust-src"
                "rust-analyzer"
                "clippy"
              ];
            };
          };

          my-crate.craneLib = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = (inputs.crane.mkLib pkgs).overrideToolchain config.my-crate.rustToolchain;
          };
        };
        config = let
          cargoToml = builtins.fromTOML (builtins.readFile (self + /Cargo.toml));
          inherit (cargoToml.package) name;
          inherit (config.my-crate) rustToolchain craneLib;

          my-crate = craneLib.buildPackage {
            src = craneLib.cleanCargoSource ./.;
            strictDeps = true;
          };
        in {
          packages.${name} = my-crate.package;
          packages."${name}-doc" = my-crate.doc;

          checks."${name}-clippy" = my-crate.check;
        };
      });
  };
}
