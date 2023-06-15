{
  description = "The rust hello project for stm32";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    stm32.url = github:ein-shved/nix-stm32;
    stm32.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, stm32, nixpkgs } :
  let
    generic = stm32.mkRustFirmware {
      pname = "hello_rust";
      version = "0.1.0";
      mcu = stm32.mcus.stm32f103;
      src = ./generic/.;
      cargoLock = {
        lockFile = ./generic/Cargo.lock;
      };
    };
    embassy = stm32.mkRustFirmware {
      pname = "hello_embassy";
      version = "0.1.0";
      mcu = stm32.mcus.stm32f103;
      nightly = true;
      buildPackage = false; # TODO (Shvedov) failed to build embassy libs
                            # with nix as dependency to this package
      src = ./embassy/.;
      cargoLock = {
        lockFile = ./embassy/Cargo.lock;
        outputHashes = {
          "embassy-embedded-hal-0.1.0" =
            "sha256-zBxLMNGqspi2dWvbVq1b50MWlkrdUhuv52L1w/pc3+w=";
        };
      };
    };
  in
  stm32.mergeFirmwares {
    inherit generic embassy;
    default = embassy;
  };
}
