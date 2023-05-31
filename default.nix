{ pkgs ? import <nixpkgs> {
    crossSystem = (import <nixpkgs/lib>).systems.examples.arm-embedded // {
      rustc.config = "thumbv7em-none-eabi";
    };
  }
} : pkgs.rustPlatform.buildRustPackage rec {
      pname = "hello_rust";
      version = "0.1.0";
      cargoLock = {
        lockFile = ./Cargo.lock;
      };
      src = ./.;
}
