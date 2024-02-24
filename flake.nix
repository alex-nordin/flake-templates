
{
  description = "Alex' flake templates";

  outputs = { self, ... }: {
    templates = {
      rust-dev = {
        path = ./rust-dev-template;
        description = "A template for Rust development, with devenv and flake-parts";
      };
    };
  };
}
