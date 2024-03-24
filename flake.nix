{
  description = "Alex' flake templates";

  outputs = {self, ...}: {
    templates = {
      rust-dev = {
        path = ./rust-dev-template;
        description = "A template for Rust development, with devenv and flake-parts";
      };
      stm-c-dev = {
        path = ./stm-c-template;
        description = "A template for a C dev-env for stm32f3, with code generation and flashing";
      };
      c-meson = {
        path = ./c_meson;
        description = "A template for C++ projects using meson to build";
      };
    };
  };
}
