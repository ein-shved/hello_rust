{
  description = "The rust hello project for stm32";

  inputs = {
    nixpkgs.url = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (localSystem:
      let
        target = "thumbv7m-none-eabi";
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit localSystem overlays;
        };
        rustVersion = pkgs.rust-bin.stable.latest.default.override {
          targets = [ target ];
        };

        hello_rust = pkgs.rustPlatform.buildRustPackage {
          pname = "hello_rust";
          version = "0.1.0";
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          doCheck = false;
          src = ./.;
          nativeBuildInputs = with pkgs; [
            rustVersion
            probe-run
          ];
          buildPhase = ''
            runHook preBuild
            ${rustVersion}/bin/cargo build -j $NIX_BUILD_CORES --frozen
            runHook postBuild
          '';
          dontCargoInstall = true;
          installPhase = ''
            mkdir -p $out/bin
            ${rustVersion}/bin/cargo install -j $NIX_BUILD_CORES --root $out --path .
          '';
        };
        runner = pkgs.writeShellScriptBin "hello_rust" ''
          ${pkgs.probe-run}/bin/probe-run --chip STM32F103C8 \
            $(find ${hello_rust} -type f -executable)
        '';
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = with pkgs; [
            rustVersion
            probe-run
          ];
        };
        packages = {
          default = hello_rust;
          inherit (pkgs) rust-bin;
        };
        apps.default = flake-utils.lib.mkApp { drv = runner; };
      }
    );
}
