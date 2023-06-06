{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (localSystem:
      let
        pkgs = nixpkgs.legacyPackages.${localSystem};
        crossPkgs = import nixpkgs {
          inherit localSystem;
          crossSystem =
            {
              config = "arm-none-eabi";
              rustc.config = "thumbv7em-none-eabi";
              #rustc.platform = {
              #  arch = "arm";
              #  abi = "eabi";
              #  c-enum-min-bits = 8;
              #  data-layout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64";
              #  emit-debug-gdb-scripts = false;
              #  frame-pointer = "always";
              #  is-builtin = true;
              #  linker = "rust-lld";
              #  linker-flavor = "ld.lld";
              #  llvm-target = "thumbv7em-none-eabi";
              #  max-atomic-width = 32;
              #  panic-strategy = "abort";
              #  relocation-model = "static";
              #  target-pointer-width = "32";
              #};
            };
        };
        hello_rust = crossPkgs.rustPlatform.buildRustPackage {
          pname = "hello_rust";
          version = "0.1.0";
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          doCheck = false;
          #nativeBuildInputs = [ pkgs.rustup pkgs.cargo-binutils ];
          src = ./.;
          meta.platforms = [
            "arm-none"
            "armhf-none"
          ];
        };
      in
      {
        packages.default = hello_rust;
      }
    );
}
