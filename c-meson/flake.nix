{
  description = "Dev shell wish meson build system for C";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
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
        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = {
          pnaame = "placeholder";
          src = ./.;
          nativebuildInputs = with pkgs; [meson ninja pkg-config gcc];

          meta = with lib; {
            # homepage = "https://github.com/alex-nordin/PLACEHOLDER";
            license = with licenses; [mit];
            maintainers = ["Alex Nordin"];
          };
        };
        devenv.shells.default = {
          packages = with pkgs; [
            meson
            ninja
            gcc
            clang-tools
          ];
        };
      };
    };
}
