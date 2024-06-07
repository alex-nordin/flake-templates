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
      c-meson-dev = {
        path = ./c-meson;
        description = "A template for C++ projects using meson to build";
      };
      esp-c-dev = {
        path = ./esp-c;
        description = "A template for esp develpoment in C";
      };
      esp-rust-std = {
        path = ./esp-idf-alt;
        description = "A template for Rust development on esp with std";
      };
    };
  };
}
